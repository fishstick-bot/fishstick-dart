import "../client/client.dart";
import "package:mongo_dart/mongo_dart.dart";

class Database {
  /// The main bot client.
  late final Client _client;

  /// The database connection.
  late final Db db;

  /// users collections
  late DbCollection users;

  /// discord guilds collections
  late DbCollection guilds;

  /// stw leaderboards collections
  late DbCollection leaderboards;

  /// The database object
  Database(this._client) {
    db = Db(_client.config.mongoUri);
  }

  /// connect to the database
  Future<void> connect() async {
    await db.open();

    users = db.collection("users");
    guilds = db.collection("guilds");
    leaderboards = db.collection("leaderboards");
  }
}
