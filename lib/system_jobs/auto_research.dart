import "package:nyxx/nyxx.dart";
import "package:mongo_dart/mongo_dart.dart";

import "abstract_system_job.dart";
import "../client/client.dart";
import "../database/database_user.dart";
import "../resources/emojis.dart";
import "../utils/utils.dart";

class AutoResearchSystemJob extends AbstractUserSystemJob {
  /// Creates a new instance of the [AutoResearchSystemJob] class.
  AutoResearchSystemJob(Client _c)
      : super(
          _c,
          name: "auto_research",
          delay: Duration(seconds: 1),
        );

  @override
  Future<List<DatabaseUser>> fetchUsers() async {
    users = [];
    var _stream = client.database.users
        .find(where.eq("autoSubscriptions.collectResearchPoints", true));

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
      /// telegram users not supported for auto daily just yet.
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
        for (final acc in accs) {
          String message = "";
          try {
            var fnClient = user.fnClientSetup(acc.accountId);

            await fnClient.campaign.init(acc.accountId);
            var current = fnClient.campaign.researchLevels;
            for (final stat in [
              "fortitude",
              "resistance",
              "offense",
              "technology"
            ]) {
              if (current[stat] == null) {
                current[stat] = 0;
              }
            }
            current.removeWhere((key, value) => value >= 120);
            if (current.isEmpty) {
              continue accLoop;
            }

            var upgraded = Map.from(current);

            for (final stat in current.keys) {
              innerLoop:
              for (var i = 0; i < 3; i++) {
                try {
                  await fnClient.campaign.upgradeResearchStat(stat);
                  upgraded[stat] += 1;
                } catch (_) {
                  break innerLoop;
                }
              }
            }

            message = "**${acc.displayName}** ${tick.emoji}\n";
            message += upgraded.entries
                .map((e) =>
                    "• ${(e.key as String).toUpperCase()}: ~~${current[e.key]}~~ -> **${e.value}**")
                .join("\n");
          } catch (e) {
            message = "**${acc.displayName}** ${cross.emoji}\n$e";
          }
          description += message;
          description += "\n";
          description += "\n";
        }

        try {
          if (user.dmNotifications && description.isNotEmpty) {
            await discordUser.sendMessage(
              MessageBuilder.embed(
                EmbedBuilder()
                  ..author = (EmbedAuthorBuilder()
                    ..name = discordUser.username
                    ..iconUrl = discordUser.avatarURL(format: "png"))
                  ..title = "Auto Research | Save the World"
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
}
