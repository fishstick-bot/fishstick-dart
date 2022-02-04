import "dart:async";
import "package:numeral/numeral.dart";
import "package:logging/logging.dart";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../database/database.dart";
import "../config.dart";

import "../utils/utils.dart";
import "../utils/image_utils.dart";
import "../utils/commands_handler.dart";

import "../system_jobs/system_jobs.dart";

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

  /// Image utils for the client
  late ImageUtils imageUtils;

  /// Cached cosmetics for the client
  List<Map<String, dynamic>> cachedCosmetics = [];

  /// System jobs manager
  late SystemJobsPlugin systemJobs;

  // Footer text
  String footerText = "discord.gg/fishstick";

  /// prefix for commands
  String prefix = ".";

  /// global commands cooldown
  int commandsCooldown = 4;

  Client() {
    /// setup logger
    Logger.root.level = Level.INFO;

    /// setup system jobs manager
    systemJobs = SystemJobsPlugin(this);

    /// setup commands
    commands = CommandsPlugin(
      prefix: dmOr((_) => "."),
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
    handleCommandsError(this);

    /// handle commands check
    handleCommandsCheckHandler(this);

    /// handle commands post call
    handleCommandsPostCall(this);

    /// setup database
    database = Database(this);

    /// setup image utils
    imageUtils = ImageUtils(this);

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
      ..registerPlugin(commands)
      ..registerPlugin(systemJobs);

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
  }

  /// Start the client.
  /// This will connect to the bot to discord and database.
  Future<void> start() async {
    int _start;

    _start = DateTime.now().millisecondsSinceEpoch;
    await database.connect();
    logger.info(
        "Connected to database [${(DateTime.now().millisecondsSinceEpoch - _start).toStringAsFixed(2)}ms]");

    _start = DateTime.now().millisecondsSinceEpoch;
    await bot.connect();
    logger.info(
        "Connected to discord [${(DateTime.now().millisecondsSinceEpoch - _start).toStringAsFixed(2)}ms]");
  }

  /// encrypt a string
  String encryptString(String text) => encrypt(text);

  /// decrypt a string
  String decryptString(String text) => decrypt(text);
}
