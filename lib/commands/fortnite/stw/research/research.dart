import "package:nyxx_commands/nyxx_commands.dart";

import "collect.dart";
import "upgrade.dart";

final ChatGroup stwResearchCommand = ChatGroup(
  "research",
  "Save the world research.",
  children: [
    collectResearchCommand,
    upgradeResearchCommand,
  ],
  checks: [],
);
