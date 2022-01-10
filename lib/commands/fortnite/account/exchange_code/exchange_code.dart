import "package:nyxx_commands/nyxx_commands.dart";
import "create.dart";

final Group exchangeCodeCommand = Group(
  "exchange-code",
  "Exchange code commands.",
  children: [
    exchangeCodeCreateCommand,
  ],
  checks: [],
);
