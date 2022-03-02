import "package:mongo_dart/mongo_dart.dart";

import "abstract_system_job.dart";
import "../client/client.dart";
import "../database/database_user.dart";
import "../utils/utils.dart";

class ClaimResearchPointsSystemJob extends AbstractUserSystemJob {
  /// Creates a new instance of the [ClaimResearchPointsSystemJob] class.
  ClaimResearchPointsSystemJob(Client _c)
      : super(
          _c,
          name: "collect_research_points",
          delay: Duration(seconds: 1),
        );

  @override
  Future<List<DatabaseUser>> fetchUsers() async {
    // users = [await client.database.getUser("727224012912197652")];
    // return users;
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
      /// no use of running the function if user has no linked accounts.
      if (user.linkedAccounts.isEmpty) {
        return;
      }

      for (final acc in [...user.linkedAccounts]) {
        try {
          var fnClient = user.fnClientSetup(acc.accountId);
          await fnClient.campaign.init(fnClient.accountId);
          await fnClient.campaign.collectResearchPoints();
        } catch (_) {
          // SILENTLY IGNORE THE EXCEPTION
        }
      }
    } catch (e) {
      client.logger.shout("[TASK:$name:${user.id}] Unhandled error: $e");
      await notifyErrorEvent(source: "TASK:$name:${user.id}", error: "$e");
    }

    return;
  }
}
