import "dart:async";
import "dart:math";
import "package:numeral/numeral.dart";
import "package:logging/logging.dart";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../extensions/context_extensions.dart";
import "../database/database.dart";
// import "../database/database_user.dart";
// import "../database/database_guild.dart";
import "../config.dart";
import "../utils/utils.dart";

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

    /// dispose command cache
    commands.onPostCall.listen((ctx) {
      ctx.disposeCache();
    });

    /// listen for commands error and handle them
    commands.onCommandError.listen((exception) async {
      if (exception is CommandNotFoundException) {
        return;
      }

      if (exception is CommandInvocationException) {
        exception.context.disposeCache();
      }

      if (exception is CheckFailedException) {
        switch (exception.failed.name) {
          case "blacklist-check":
            await respond(
              exception.context,
              MessageBuilder.content("You are blacklisted from using the bot!"),
              hidden: true,
            );
            break;

          case "premium-check":
            break;

          case "partner-check":
            await respond(
              exception.context,
              MessageBuilder.content(
                  "You need Fishstick partner to use this command.\nDM Vanxh#6969 for more info."),
              hidden: true,
            );
            break;

          case "owner-check":
            await respond(
              exception.context,
              MessageBuilder.content(
                  "You need to be the owner of the bot to use this command."),
              hidden: true,
            );
            break;

          case "guild-check":
            await respond(
              exception.context,
              MessageBuilder.content("This command can not be done on DMs."),
              hidden: true,
            );
            break;

          case "cooldown-check":
            var m = await respond(
              exception.context,
              MessageBuilder.content(
                  "You are on cooldown for this command. Please try again in a while."),
              hidden: true,
            );
            await Future.delayed(
              Duration(seconds: 2),
              () async => await m.delete(),
            );
            break;

          default:
            logger.shout("Unhandled check exception: ${exception.failed.name}");
            break;
        }
      } else if (exception is BadInputException) {
        await respond(
          exception.context,
          MessageBuilder.content("An invalid argument was provided."),
          hidden: true,
        );
      } else {
        List<String> errorTitles = [
          "💥 Uh oh! That was unexpected!",
          "⚠️ Not the LLAMA you're looking for!",
          "⚠️ There was an error!",
        ];
        if (exception is CommandInvocationException) {
          await respond(
            exception.context,
            MessageBuilder.embed(
              EmbedBuilder()
                ..title = errorTitles[Random().nextInt(errorTitles.length)]
                ..color = DiscordColor.red
                ..timestamp = DateTime.now()
                ..footer = (EmbedFooterBuilder()
                  ..text = exception.runtimeType.toString())
                ..description =
                    "An error has occurred!\nYou can join our [support server](${config.supportServer}) to report the bug if you feel its a bug."
                ..addField(
                  name: "Error",
                  content: exception.message,
                ),
            ),
            hidden: true,
          );
        } else {
          logger.shout("Unhandled exception type: ${exception.runtimeType}");
        }
      }
    });

    /// user blacklist check for commands
    commands.check(
      Check((ctx) async => !(await ctx.dbUser).isBanned, "blacklist-check"),
    );

    /// cooldown check for commands
    // commands.check(
    //   CooldownCheck(CooldownType.user, Duration(seconds: 5), 2),
    // ); // temporary cooldown system

    commands.check(
      Check.any([
        Check.all([
          premiumCheck,
          CooldownCheck(CooldownType.user, Duration(seconds: 5), 4),
        ]),
        Check.all([
          Check.deny(premiumCheck),
          CooldownCheck(CooldownType.user, Duration(seconds: 5), 2),
        ]),
      ]),
    );

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
