import "package:nyxx_commands/nyxx_commands.dart";
import "text.dart";
import "image.dart";
import "full.dart";
import "exclusives.dart";
import "crew.dart";
import "special.dart";

final ChatGroup lockerCommand = ChatGroup(
  "locker",
  "Locker related commands.",
  children: [
    lockerTextCommand,
    lockerImageCommand,
    lockerFullImageCommand,
    lockerExclusivesImageCommand,
    lockerCrewImageCommand,
    lockerSpecialImageCommand,
  ],
  checks: [],
);
