import "package:nyxx_commands/nyxx_commands.dart";

import "br.dart";

final ChatGroup shopCommand = ChatGroup(
  "shop",
  "View fortnite item shop.",
  children: [
    brShopCommand,
  ],
  aliases: ["itemshop"],
  checks: [],
);
