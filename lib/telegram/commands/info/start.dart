import "../../structures/command.dart";

final Command start = Command(
  "start",
  "Start the bot.",
  (client, msg, user) async {
    await msg.reply(
      "**Fishstick Bot**\nA better Fortnite companion\\.\nConnect your Fortnite accounts with me to generate locker images, get account statistics etc\\.",
      parse_mode: "MarkdownV2",
    );
  },
);
