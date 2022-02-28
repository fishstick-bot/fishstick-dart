import "package:nyxx_commands/nyxx_commands.dart";

import "../../../../utils/utils.dart";

import "switch.dart";

final ChatGroup heroLoadoutCommand = ChatGroup(
  "heroloadouts",
  "Manage STW hero loadouts.",
  children: [
    heroLoadoutSwitchCommand,
  ],
  checks: [premiumCheck],
);
