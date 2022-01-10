import "package:nyxx_commands/nyxx_commands.dart";
import "view.dart";
import "unlink.dart";
import "../../../../utils/utils.dart";

final Group externalsCommand = Group(
  "external",
  "Manage your account external links.",
  children: [
    externalViewCommand,
    externalUnlinkCommand,
  ],
  checks: [premiumCheck],
);
