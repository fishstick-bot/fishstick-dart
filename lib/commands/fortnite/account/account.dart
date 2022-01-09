import "package:nyxx_commands/nyxx_commands.dart";
import "token.dart";
import "botdata.dart";

final Group accountCommand = Group(
  "account",
  "Account management commands.",
  children: [
    accessTokenCommand,
    botDataCommand,
  ],
  checks: [],
);
