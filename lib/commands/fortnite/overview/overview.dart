import "package:nyxx_commands/nyxx_commands.dart";
import "br.dart";
import "stw.dart";

final Group overviewCommand = Group(
  "overview",
  "View your different game modes profile overview.",
  children: [
    overviewBRCommand,
    overviewSTWCommand,
  ],
  aliases: ["ovw"],
  checks: [],
);
