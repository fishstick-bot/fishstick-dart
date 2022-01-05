import "package:nyxx_commands/nyxx_commands.dart";
import "../fishstick_dart.dart";
import "../database/database_user.dart";

Map<String, DatabaseUser> cachedDbUsers = {};

extension DBUser on Context {
  /// fetch the db user from the cache or database
  Future<DatabaseUser> get dbUser async {
    cachedDbUsers[user.id.toString()] ??=
        await client.database.getUser(user.id.toString());
    return cachedDbUsers[user.id.toString()] ??
        await client.database.getUser(user.id.toString());
  }

  /// dispose the cached db user
  void disposeDbUser() {
    cachedDbUsers.remove(user.id.toString());
  }
}
