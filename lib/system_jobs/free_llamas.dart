import "package:nyxx/nyxx.dart";
import "package:mongo_dart/mongo_dart.dart";
import "package:fortnite/fortnite.dart" as fn;

import "abstract_system_job.dart";
import "../client/client.dart";
import "../database/database_user.dart";
import "../resources/emojis.dart";
import "../utils/utils.dart";

class ClaimFreeLlamasSystemJob extends AbstractUserSystemJob {
  /// Creates a new instance of the [ClaimFreeLlamasSystemJob] class.
  ClaimFreeLlamasSystemJob(Client _c)
      : super(
          _c,
          name: "free_llamas",
          delay: Duration(seconds: 1),
        );

  @override
  Future<List<DatabaseUser>> fetchUsers() async {
    // users = [await client.database.getUser("727224012912197652")];
    // return users;
    users = [];
    var _stream = client.database.users
        .find(where.eq("autoSubscriptions.freeLlamas", true));

    await for (final u in _stream) {
      if (u["id"] == null) continue;
      users.add(DatabaseUser.fromJson(client.database, u));
    }

    users = users.where((u) => u.isPremium).toList();

    return users;
  }

  @override
  Future<dynamic> performOnUser(DatabaseUser user) async {
    client.logger.info("[TASK:$name:${user.id}] Starting...");
    try {
      /// telegram users not supported for auto free llamas just yet.
      if (!user.isDiscordUser) {
        return;
      }

      /// no use of running the function if user has no linked accounts.
      if (user.linkedAccounts.isEmpty) {
        return;
      }

      var accChunks = user.linkedAccounts.chunk(5);

      var discordUser = await client.bot.fetchUser(user.id.toSnowflake());

      await for (final accs in accChunks) {
        String description = "";

        accLoop:
        for (final acc in [...accs]) {
          String message = "";

          int nClaimed = 0;
          try {
            var fnClient = user.fnClientSetup(acc.accountId);
            final String? availableFreeLlama =
                await _getAvailableFreeLlama(fnClient);
            if (availableFreeLlama == null) {
              await Future.delayed(Duration(
                  seconds: 2)); // ADD A DELAY OF 2s AS NO FREE LLAMAS AVAILABLE
              continue accLoop;
            }

            await populatePrerolledOffers(fnClient);
            await purchaseCatalogEntry(
              availableFreeLlama,
              client: fnClient,
              currency: "GameItem",
              currencySubType: "AccountResource:currency_xrayllama",
            );
            nClaimed += 1;

            try {
              final String? availableFreeLlama =
                  await _getAvailableFreeLlama(fnClient);
              if (availableFreeLlama != null) {
                await populatePrerolledOffers(fnClient);
                await purchaseCatalogEntry(
                  availableFreeLlama,
                  client: fnClient,
                  currency: "GameItem",
                  currencySubType: "AccountResource:currency_xrayllama",
                );
                nClaimed += 1;
              }
            } on Exception {
              nClaimed += 0;
            }

            message = "**${acc.displayName}** ${tick.emoji}\n";
            message += "Successfully claimed $nClaimed free llama(s).";
          } on Exception catch (e) {
            message = "**${acc.displayName}** ${cross.emoji}\n$e";
          }

          if (nClaimed == 0) {
            continue accLoop;
          }

          description += message;
          description += "\n";
          description += "\n";
        }

        try {
          if (description.isNotEmpty && user.dmNotifications) {
            await discordUser.sendMessage(
              MessageBuilder.embed(
                EmbedBuilder()
                  ..author = (EmbedAuthorBuilder()
                    ..name = discordUser.username
                    ..iconUrl = discordUser.avatarURL(format: "png"))
                  ..title = "Auto Free Llama(s) | Save the World"
                  ..color = DiscordColor.fromHexString(user.color)
                  ..timestamp = DateTime.now()
                  ..description = description,
              ),
            );
          }
        } catch (e) {
          /// ignore the [Exception] as bot is not able to send message to user.
          /// just to be sure log the error.
          client.logger.shout(
              "[TASK:$name:${user.id}] Failed to send message to user: $e");
        }
      }
    } catch (e) {
      client.logger.shout("[TASK:$name:${user.id}] Unhandled error: $e");
      await notifyErrorEvent(source: "TASK:$name:${user.id}", error: "$e");
    }

    return;
  }

  /// Fetches the available free llama from fortnite catalog.
  Future<String?> _getAvailableFreeLlama(fn.Client _client) async {
    try {
      var storefronts = ((await _client.get(fn.Endpoints().fortniteCatalog)
              as Map<String, dynamic>)["storefronts"] as List<dynamic>)
          .where((s) =>
              s["name"] == "CardPackStorePreroll" ||
              s["name"] == "CardPackStoreGameplay")
          .map((s) => s["catalogEntries"] as List<dynamic>)
          .fold<List<dynamic>>([], (a, b) => a + b).where((i) =>
              (i["devName"] ?? "").toString().contains("RandomFree") ||
              (i["devName"] ?? "").toString().contains("FreePack") ||
              (i["title"] ?? "").toString().contains("Seasonal Sale Freebie"));

      if (storefronts.isEmpty) {
        return null;
      }

      return storefronts.first["offerId"]?.toString();
    } catch (e) {
      client.logger.shout(
          "[TASK:$name] Unhandled error while retreiving free llamas: $e");
      return null;
    }
  }

  /// Need to do this before buying any llama in fortnite stw.
  Future<void> populatePrerolledOffers(fn.Client _client) async {
    return await _client.post(fn
        .MCP(fn.FortniteProfile.campaign, accountId: _client.accountId)
        .PopulatePrerolledOffers);
  }
}
