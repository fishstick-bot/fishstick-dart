import "package:nyxx_commands/nyxx_commands.dart";
import "token.dart";
import "exchange_code.dart";
import "page.dart";
import "botdata.dart";
import "receipts.dart";

final Group accountCommand = Group(
  "account",
  "Account management commands.",
  children: [
    accessTokenCommand,
    exchangeCodeCommand,
    accountSettingsPageCommand,
    botDataCommand,
    accountReceiptsCommand,
  ],
  checks: [],
);
