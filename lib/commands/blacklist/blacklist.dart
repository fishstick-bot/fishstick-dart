import "package:nyxx_commands/nyxx_commands.dart";
import "add.dart";
import "remove.dart";

final Group blacklistCommand = Group(
  "blacklist",
  "Add/Remove a user from bot's blacklist .",
  children: [
    blacklistAddCommand,
    blacklistRemoveCommand,
  ],
);
