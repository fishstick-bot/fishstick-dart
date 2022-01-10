import "package:nyxx_commands/nyxx_commands.dart";
import "view.dart";
import "change.dart";
import "../../../../utils/utils.dart";

final Group usernameCommand = Group(
  "username",
  "Manage your account username information.",
  children: [
    usernameViewCommand,
    usernameChangeCommand,
  ],
  checks: [premiumCheck],
);
