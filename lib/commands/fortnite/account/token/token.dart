import "package:nyxx_commands/nyxx_commands.dart";
import "create.dart";
import "delete.dart";
import "delete_multiple.dart";
import "../../../../utils/utils.dart";

final Group accessTokenCommand = Group(
  "token",
  "Access token commands.",
  children: [
    accessTokenCreateCommand,
    accessTokenDeleteCommand,
    accessTokenDeleteAllCommand,
  ],
  checks: [premiumCheck],
);
