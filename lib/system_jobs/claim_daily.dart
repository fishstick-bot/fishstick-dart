import "package:nyxx/nyxx.dart";
import "package:mongo_dart/mongo_dart.dart";

import "abstract_system_job.dart";
import "../client/client.dart";
import "../database/database_user.dart";
import "../resources/emojis.dart";
import "../utils/utils.dart";

class ClaimDailySystemJob extends AbstractUserSystemJob {
  /// Creates a new instance of the [ClaimDailySystemJob] class.
  ClaimDailySystemJob(Client _c)
      : super(
          _c,
          name: "claim_daily",
          delay: Duration(seconds: 1),
        );

  @override
  Future<List<DatabaseUser>> fetchUsers() async {
    // users = [await client.database.getUser("727224012912197652")];
    // return users;
    users = [];
    var _stream = client.database.users
        .find(where.eq("autoSubscriptions.dailyRewards", true));

    await for (final u in _stream) {
      if (u["id"] == null) continue;
      users.add(DatabaseUser.fromJson(client.database, u));
    }

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

      var accChunks = await user.linkedAccounts.chunk(5).toList();

      var discordUser = await client.bot.fetchUser(user.id.toSnowflake());

      for (final accs in accChunks) {
        String description = "";

        for (final acc in accs) {
          String message = "";
          try {
            var fnClient = user.fnClientSetup(acc.accountId);
            var claimed = await fnClient.campaign.claimDailyReward();

            message = "**${acc.displayName}** ${tick.emoji}\n";
            message += claimed.alreadyClaimed
                ? "You have already claimed todays reward."
                : "Successfully claimed todays reward.";
            message += "\n";
            message +=
                "Day ${claimed.daysLoggedIn} - **${claimed.rewardsByDay.first.amount}x ${claimed.rewardsByDay.first.name}**";
            if (claimed.rewardsByDay.length > 1) {
              message += "\n";
              message +=
                  "Day ${claimed.daysLoggedIn + 1} - **${claimed.rewardsByDay[1].amount}x ${claimed.rewardsByDay[1].name}**";
            }
          } catch (e) {
            message = "**${acc.displayName}** ${cross.emoji}\n$e";
          }
          description += message;
          description += "\n";
          description += "\n";
        }

        try {
          if (user.dmNotifications) {
            await discordUser.sendMessage(
              MessageBuilder.embed(
                EmbedBuilder()
                  ..author = (EmbedAuthorBuilder()
                    ..name = discordUser.username
                    ..iconUrl = discordUser.avatarURL(format: "png"))
                  ..title = "Auto Daily Login Rewards | Save the World"
                  ..color = DiscordColor.fromHexString(user.color)
                  ..timestamp = DateTime.now()
                  ..description = description,
              ),
            );
          }
        } on Exception catch (e) {
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
