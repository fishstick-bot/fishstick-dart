import "package:nyxx_commands/nyxx_commands.dart";
import "view.dart";
import "first.dart";

final Group realNameCommand = Group(
  "realname",
  "Manage your account real name information.",
  children: [
    realNameViewCommand,
    realNameFirstCommand,
  ],
  checks: [],
);
