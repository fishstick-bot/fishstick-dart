import "package:nyxx_commands/nyxx_commands.dart";
import "view.dart";
import "change.dart";

final ChatGroup affiliateCommand = ChatGroup(
  "sac",
  "Manage your supported creator in item shop.",
  children: [
    affiliateViewCommand,
    affiliateChangeCommand,
  ],
  aliases: ["cc"],
  checks: [],
);
