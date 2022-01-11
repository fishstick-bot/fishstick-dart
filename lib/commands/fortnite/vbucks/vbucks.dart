import "package:nyxx_commands/nyxx_commands.dart";
import "balance.dart";

final Group vbucksCommand = Group(
  "vbucks",
  "V-Bucks related commands.",
  children: [
    vbucksBalanceCommand,
  ],
  aliases: ["vb"],
  checks: [],
);
