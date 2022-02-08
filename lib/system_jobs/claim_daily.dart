import "package:nyxx/nyxx.dart";
import "package:mongo_dart/mongo_dart.dart";

import "abstract_system_job.dart";
import "../client/client.dart";
import "../database/database_user.dart";

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
    users = [await client.database.getUser("727224012912197652")];
    return users;
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
    client.logger.info("[TASK:$name:id] Starting...");
    try {
      if (!user.isDiscordUser) {
        return;
      }

      var _discordUser = await client.bot.fetchUser(user.id.toSnowflake());
    } catch (e) {
      client.logger.shout("[TASK:$name:id] Unhandled error: $e");
    }
  }
}
