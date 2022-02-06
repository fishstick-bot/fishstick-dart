import "package:logging/logging.dart";

import "package:teledart/teledart.dart";
import "package:teledart/telegram.dart";
import "package:teledart/model.dart";

import "../../client/client.dart" show Client;

import "../structures/command.dart";

import "../commands/info/start.dart";
import "../commands/info/ping.dart";

class TeleBotClient {
  /// logger
  final Logger logger = Logger("TELEGRAM");

  /// main client
  late final Client _client;

  /// username of bot
  late final String username;

  /// [TeleDart] instance
  late final TeleDart bot;

  /// [Telegram] instance
  late final Telegram telegram;

  /// [Command]s list
  final List<Command> commands = [];

  /// connection retries
  int _retries = 0;

  TeleBotClient(this._client) {
    commands.add(start);
    commands.add(ping);
  }

  Future<void> connect() async {
    try {
      telegram = Telegram(_client.config.telegramToken);

      username = (await telegram.getMe()).username ?? "";
      logger.info("Connected to telegram as @$username");

      bot = TeleDart(_client.config.telegramToken, Event(username));
      bot.start();

      List<BotCommand> _teleCommands = [];
      for (final command in commands) {
        _teleCommands.add(BotCommand(
          command: command.name,
          description: command.description,
        ));

        bot.onCommand(command.name).listen((msg) async {
          if (msg.from == null) return;
          if (msg.from!.is_bot) return;

          if (Duration(
                      milliseconds: DateTime.now().millisecondsSinceEpoch -
                          (msg.date * 1000))
                  .inMinutes >
              1) return;

          logger.info(
              "Executing command with hash [${command.name}] from ${msg.from!.id}");

          try {
            final user =
                await _client.database.getUser(msg.from!.id.toString());

            if (user.isBanned) {
              await msg.reply("You are banned from using this bot.");
              return;
            }

            if (command.isOwnerOnly &&
                _client.config.telegramOwnerId != user.id) {
              await msg.reply("Only bot owner can use this command.");
              return;
            }

            if (command.isPartnerOnly && !user.isPartner) {
              await msg.reply("Only partners can use this command.");
              return;
            }

            if (command.isPremiumOnly && !user.isPremium) {
              await msg.reply("Only premium users can use this command.");
              return;
            }

            await command.handle(this, msg, user);
          } catch (e) {
            logger.severe("Error executing command ${command.name}", e);

            msg.reply(
                "Error executing command ${command.name}\n\n${e.toString()}");
          }
        });
      }

      await telegram.setMyCommands(_teleCommands);
      logger.info("Successfully set commands to telegram.");
    } catch (e) {
      if (_retries >= 5) {
        logger.severe("Failed to connect to telegram.", e);
        return;
      }

      _retries++;
      logger.shout(
          "Retry $_retries/5 | Unable to connect to telegram, retrying in 30s",
          e);

      return Future.delayed(Duration(seconds: 30), () async => await connect());
    }
  }
}
