import "../../structures/command.dart";

final Command stop = Command(
  "stop",
  "Stop the bot.",
  (client, msg, user) async {
    await client.bot.leaveChat(msg.chat.id);
  },
);
