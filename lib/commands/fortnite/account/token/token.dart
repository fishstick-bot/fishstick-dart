import "package:nyxx_commands/nyxx_commands.dart";
import "create.dart";

final Group accessTokenCommand = Group(
  "token",
  "Access token commands.",
  children: [
    accessTokenCreateCommand,
  ],
  checks: [],
);
