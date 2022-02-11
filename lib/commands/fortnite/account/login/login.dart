import "package:nyxx_commands/nyxx_commands.dart";
import "switch.dart";
import "new.dart";
import "code.dart";

final ChatGroup loginCommand = ChatGroup(
  "login",
  "Switch current active account or Login to a new epic account.",
  children: [
    loginSwitchCommand,
    loginNewCommand,
    loginCodeCommand,
  ],
);
