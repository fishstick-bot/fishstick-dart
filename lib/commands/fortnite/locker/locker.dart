import "package:nyxx_commands/nyxx_commands.dart";
import "text.dart";
import "image.dart";
import "exclusives.dart";

final Group lockerCommand = Group(
  "locker",
  "Locker related commands.",
  children: [
    lockerTextCommand,
    lockerImageCommand,
    lockerExclusivesImageCommand,
  ],
  checks: [],
);
