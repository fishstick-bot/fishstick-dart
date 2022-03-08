import "package:nyxx_commands/nyxx_commands.dart";

import "backpack.dart";
import "storage.dart";
import "ventures.dart";
import "backpack_and_storage.dart";

final ChatGroup inventoryCommand = ChatGroup(
  "inventory",
  "View your STW inventory.",
  children: [
    backpackInventoryCommand,
    storageInventoryCommand,
    venturesInventoryCommand,
    backpackAndStorageInventoryCommand,
  ],
  checks: [],
);
