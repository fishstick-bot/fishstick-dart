import "package:nyxx_commands/nyxx_commands.dart";
import "create.dart";

final ChatGroup exchangeCodeCommand = ChatGroup(
  "exchange-code",
  "Exchange code commands.",
  children: [
    exchangeCodeCreateCommand,
  ],
  checks: [],
);
