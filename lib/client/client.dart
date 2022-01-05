import "dart:async";
import "package:logging/logging.dart";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../extensions/context_extensions.dart";
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

  /// Commands for the client
  late CommandsPlugin commands;

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
      Timer.periodic(Duration(seconds: 10), (timer) {
        print("${_bot.guilds.length} Guilds");
      });
    });

    /// setup database
    database = Database(this);

    /// setup commands
    commands = CommandsPlugin(
      prefix: (_) => ".",
      guild: config.developmentMode ? null : Snowflake(config.developmentGuild),
      options: CommandsOptions(
        logErrors: true,
        acceptBotCommands: false,
        acceptSelfCommands: false,
        autoAcknowledgeInteractions: true,
      ),
    );

    /// listen for commands error and handle them
    commands.onCommandError.listen((exception) {
      if (exception is CheckFailedException) {
        switch (exception.failed.name) {
          case "blacklist-check":
            break;

          case "premium-check":
            break;

          case "cooldown-check":
            break;

          default:
            break;
        }
      } else {}
    });

    /// user blacklist check for commands
    commands.check(
      Check((ctx) async => !(await ctx.dbUser).isBanned, "blacklist-check"),
    );

    /// cooldown check for commands
    // commands.check(Check.any([
    //     Check.all([
    //         Check(
    //             (ctx) async => !(await ctx.dbUser).isPremium, "premium-check"),
    //         CooldownCheck(CooldownType.user, Duration(seconds: 5),
    //             4)]), // Premium cooldown
    //     Check.all([
    //         Check.deny(Check(
    //             (ctx) async => !(await ctx.dbUser).isPremium, "premium-check")),
    //         CooldownCheck(CooldownType.user, Duration(seconds: 5),
    //             2)]) // Non-premium cooldown
    //     )]);
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
