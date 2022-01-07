import "dart:async";
import "package:numeral/numeral.dart";
import "package:logging/logging.dart";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../database/database.dart";
import "../config.dart";
import "../utils/utils.dart";
import "../utils/commands_handler.dart";

class Client {
  /// Configuration for the client
  late final Config config = Config();

  /// logger
  final Logger logger = Logger("BOT");

  /// The nyxx client
  late INyxxWebsocket bot;

  /// The database for the bot
  late Database database;

  /// Commands for the client
  late CommandsPlugin commands;

  // Footer text
  String footerText = "discord.gg/fishstick";

  Client() {
    /// setup logger
    Logger.root.level = Level.INFO;

    /// setup commands
    commands = CommandsPlugin(
      prefix: (_) => ".",
      guild: config.developmentMode ? Snowflake(config.developmentGuild) : null,
      options: CommandsOptions(
        logErrors: true,
        acceptBotCommands: false,
        acceptSelfCommands: false,
        autoAcknowledgeInteractions: true,
        hideOriginalResponse: false,
      ),
    );

    /// handle commands error
    handleCommandsError();

    /// handle commands check
    handleCommandsCheckHandler();

    /// handle commands post call
    handleCommandsPostCall();

    /// setup discord client
    bot = NyxxFactory.createNyxxWebsocket(
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
      ..registerPlugin(IgnoreExceptions())
      ..registerPlugin(commands);

    bot.onReady.listen((_) {
      Timer.periodic(Duration(minutes: 1), (timer) {
        bot.setPresence(
          PresenceBuilder.of(
            activity: ActivityBuilder.game(
                "/help | ${Numeral(bot.guilds.length).value()} Guilds"),
            status: UserStatus.online,
          ),
        );
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
    await bot.connect();
    logger.info(
        "Connected to discord [${(DateTime.now().millisecondsSinceEpoch - start).toStringAsFixed(2)}ms]");

    start = DateTime.now().millisecondsSinceEpoch;
    await database.connect();
    logger.info(
        "Connected to database [${(DateTime.now().millisecondsSinceEpoch - start).toStringAsFixed(2)}ms]");
  }

  /// encrypt a string
  String encryptString(String text) => encrypt(text);

  /// decrypt a string
  String decryptString(String text) => decrypt(text);
}
