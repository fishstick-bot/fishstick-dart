import "package:nyxx_commands/nyxx_commands.dart";

import "br.dart";

final ChatGroup buyCommand = ChatGroup(
  "buy",
  "Buy from fortnite item shop.",
  children: [
    brBuyCommand,
  ],
  checks: [],
);
