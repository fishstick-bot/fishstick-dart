import "package:nyxx_commands/nyxx_commands.dart";
import "view.dart";
import "first.dart";
import "last.dart";
import "../../../../utils/utils.dart";

final Group realNameCommand = Group(
  "realname",
  "Manage your account real name information.",
  children: [
    realNameViewCommand,
    realNameFirstCommand,
    realNameLastCommand,
  ],
  checks: [premiumCheck],
);
