import "package:nyxx_commands/nyxx_commands.dart";
import "view.dart";
import "change.dart";
import "earnings.dart";

final ChatGroup affiliateCommand = ChatGroup(
  "sac",
  "Manage your supported creator in item shop.",
  children: [
    affiliateViewCommand,
    affiliateChangeCommand,
    affiliateEarningsCommand,
  ],
  aliases: ["cc"],
  checks: [],
);
