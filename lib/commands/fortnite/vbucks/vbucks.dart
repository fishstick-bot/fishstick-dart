import "package:nyxx_commands/nyxx_commands.dart";
import "balance.dart";
import "platform.dart";

final ChatGroup vbucksCommand = ChatGroup(
  "vbucks",
  "V-Bucks related commands.",
  children: [
    vbucksBalanceCommand,
    vbucksPlatformCommand,
  ],
  aliases: ["vb"],
  checks: [],
);
