import "package:nyxx_commands/nyxx_commands.dart";
import "view.dart";
import "unlink.dart";
import "../../../../utils/utils.dart";

final ChatGroup externalsCommand = ChatGroup(
  "external",
  "Manage your account external links.",
  children: [
    externalViewCommand,
    externalUnlinkCommand,
  ],
  checks: [premiumCheck],
);
