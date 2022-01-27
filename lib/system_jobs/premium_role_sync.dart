import "package:nyxx/nyxx.dart";

import "../fishstick_dart.dart";
import "../database/database_user.dart";

class PremiumRoleSyncSystemJob {
  final String name = "premium_role_sync";

  final Duration runDuration = Duration(hours: 12);

  /// run the task
  Future<void> run() async {
    try {
      int time = DateTime.now().millisecondsSinceEpoch;
      client.logger.info("[TASK:$name] starting...");

      final supportServer = await client.bot
          .fetchGuild(client.config.supportServerId.toSnowflake());
      var users = (client.database.users.find());

      await for (final user in users) {
        var u = DatabaseUser.fromJson(client.database, user);
        try {
          var member = await supportServer.fetchMember(u.id.toSnowflake());

          switch (u.isPremium) {
            case true:
              await member.addRole(
                  client.config.supportServerPremiumRoleId.toSnowflakeEntity());
              client.logger.info(
                  "[TASK:$name] added premium role to ${member.user.id}.");
              break;

            case false:
              await member.removeRole(
                  client.config.supportServerPremiumRoleId.toSnowflakeEntity());
              client.logger.info(
                  "[TASK:$name] removed premium role from ${member.user.id}.");
              break;
          }
        } catch (e) {
          client.logger
              .info("[TASK:$name] user ${u.id} not found in support server.");
        }

        await Future.delayed(Duration(seconds: 5));
      }

      client.logger.info(
          "[TASK:$name] finished in ${DateTime.now().millisecondsSinceEpoch - time}ms");
    } catch (e) {
      client.logger.shout(
          "[TASK:$name] An unexpected error occured retrying in 30seconds: $e");
      await Future.delayed(Duration(seconds: 30), () async => await run());
    }
    return;
  }
}
