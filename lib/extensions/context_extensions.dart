import "package:nyxx_commands/nyxx_commands.dart";
import "../fishstick_dart.dart";
import "../database/database_user.dart";
import "../database/database_guild.dart";

Map<String, DatabaseUser> cachedDbUsers = {};
Map<String, DatabaseGuild> cachedDbGuilds = {};

extension DB on Context {
  /// fetch the db user from the cache or database
  Future<DatabaseUser> get dbUser async {
    cachedDbUsers[user.id.toString()] ??=
        await client.database.getUser(user.id.toString());
    return cachedDbUsers[user.id.toString()] ??
        await client.database.getUser(user.id.toString());
  }

  /// fetch the db guild from the cache or database
  Future<DatabaseGuild?> get dbGuild async {
    if (guild?.id != null) {
      cachedDbGuilds[user.id.toString()] ??=
          await client.database.getGuild(guild?.id.toString() ?? "");
      return cachedDbGuilds[guild?.id.toString()] ??
          await client.database.getGuild(guild?.id.toString() ?? "");
    }

    return null;
  }

  /// dispose the cached db data
  void disposeCache() {
    if (cachedDbUsers.containsKey(user.id.toString())) {
      cachedDbUsers.remove(user.id.toString());
    }
    if (cachedDbGuilds.containsKey(guild?.id.toString() ?? "")) {
      cachedDbGuilds.remove(guild?.id.toString());
    }
  }
}
