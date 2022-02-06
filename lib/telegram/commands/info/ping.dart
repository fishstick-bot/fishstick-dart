import "../../structures/command.dart";

final Command ping = Command(
  "ping",
  "Ping the bot.",
  (client, msg, user) async {
    await msg.reply("🏓Pong!");
  },
);
