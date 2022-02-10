import "package:nyxx_commands/nyxx_commands.dart";

import "../../../../utils/utils.dart";

import "list.dart";
import "new.dart";
import "delete.dart";
import "equip.dart";

final ChatGroup survivorSquadPresetCommand = ChatGroup(
  "survivor-squad-preset",
  "Manage your survivor squad presets.",
  children: [
    listSurvivorSquadPresets,
    newSurvivorSquadPreset,
    deleteSurvivorSquadPreset,
    equipSurvivorSquadPreset,
  ],
  aliases: ["ssp"],
  checks: [premiumCheck],
);
