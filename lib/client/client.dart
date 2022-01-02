import "dart:async";
import "package:logging/logging.dart";
import "package:nyxx/nyxx.dart";
import "../database/database.dart";
import "../config.dart";

class Client {
  /// Configuration for the client
  late final Config config = Config();

  /// logger
  final Logger logger = Logger("BOT");

  /// The nyxx client
  late INyxxWebsocket _bot;

  /// The database for the bot
  late Database database;

  Client() {
    /// setup logger
    Logger.root.level = Level.INFO;

    /// setup discord client
    _bot = NyxxFactory.createNyxxWebsocket(
      config.token,
      GatewayIntents.allUnprivileged,
      options: ClientOptions(
        initialPresence: PresenceBuilder.of(
          activity: ActivityBuilder.game("/help"),
          status: UserStatus.online,
        ),
        dispatchRawShardEvent: true,
      ),
      useDefaultLogger: false,
    )
      ..registerPlugin(Logging())
      ..registerPlugin(CliIntegration())
      ..registerPlugin(IgnoreExceptions());

    _bot.onReady.listen((_) {
      Timer.periodic(Duration(seconds: 5), (timer) {
        print("${_bot.guilds.length} Guilds");
      });
    });

    /// setup database
    database = Database(this);
  }

  /// Start the client.
  /// This will connect to the bot to discord and database.
  Future<void> start() async {
    int start;

    start = DateTime.now().millisecondsSinceEpoch;
    await _bot.connect();
    logger.info(
        "Connected to discord [${(DateTime.now().millisecondsSinceEpoch - start).toStringAsFixed(2)}ms]");

    start = DateTime.now().millisecondsSinceEpoch;
    await database.connect();
    logger.info(
        "Connected to database [${(DateTime.now().millisecondsSinceEpoch - start).toStringAsFixed(2)}ms]");
  }
}
