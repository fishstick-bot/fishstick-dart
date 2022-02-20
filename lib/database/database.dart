import "package:mongo_dart/mongo_dart.dart";
import "database_user.dart";
import "database_guild.dart";

class Database {
  bool connected = false;

  /// The main bot client.
  late final String _mongoUri;

  /// The database connection.
  late final Db db;

  /// users collections
  late DbCollection users;

  /// discord guilds collections
  late DbCollection guilds;

  /// stw leaderboards collections
  late DbCollection leaderboards;

  /// cosmetics collections
  late DbCollection cosmetics;

  /// The database object
  Database(this._mongoUri);

  /// connect to the database
  Future<void> connect() async {
    if (connected) return;

    db = await Db.create(_mongoUri);
    await db.open();

    users = db.collection("users");
    guilds = db.collection("guilds");
    leaderboards = db.collection("leaderboards");
    cosmetics = db.collection("cosmetics");

    connected = true;
  }

  /// find or create a user
  Future<DatabaseUser> getUser(String id) async {
    var user = await users.findOne(where.eq("id", id));
    if (user == null) {
      await users.insert({
        "id": id,
        "name": "",
        "selectedAccount": "",
        "linkedAccounts": [],
        "premium": {
          "until": DateTime.now(),
          "tier": 0,
          "grantedBy": "",
        },
        "bonusAccLimit": 0,
        "autoSubscriptions": {
          "dailyRewards": false,
          "freeLlamas": false,
          "collectResearchPoints": false,
          "research": "none",
        },
        "dmNotifications": true,
        "color": "#09b7d6",
        "privacy": 0,
        "blacklisted": {
          "on": DateTime.now(),
          "value": false,
          "reason": "",
        },
        "sessions": {},
      });
      user ??= await users.findOne(where.eq("id", id));
    }

    return DatabaseUser.fromJson(this, user ?? {});
  }

  /// update the user
  Future<void> updateUser(String id, Map<String, dynamic> update) async {
    for (final key in update.keys) {
      await users.updateOne(where.eq("id", id), modify.set(key, update[key]));
    }
  }

  /// find or create a guild
  Future<DatabaseGuild> getGuild(String id) async {
    var guild = await guilds.findOne(where.eq("id", id));
    if (guild == null) {
      await guilds.insert({
        "id": id,
        "itemShopChannelID": "",
        "itemShopRoleID": "",
        "freeLlamasAlertChannelID": "",
        "freeLlamasAlertRoleID": "",
        "vbucksAlertChannelID": "",
        "vbucksAlertRoleID": "",
        "legendarySurvivorChannelID": "",
        "legendarySurvivorRoleID": "",
        "pl160alertsChannelID": "",
        "pl160alertsRoleID": "",
      });
      guild ??= await guilds.findOne(where.eq("id", id));
    }

    return DatabaseGuild.fromJson(this, guild ?? {});
  }

  /// update the guild
  Future<void> updateGuild(String id, Map<String, dynamic> update) async {
    for (final key in update.keys) {
      await guilds.updateOne(where.eq("id", id), modify.set(key, update[key]));
    }
  }
}
