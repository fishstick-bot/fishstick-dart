import "package:nyxx_commands/nyxx_commands.dart";
import "token/token.dart";
import "exchange_code/exchange_code.dart";
import "page.dart";
import "botdata.dart";
import "receipts.dart";
import "realname/realname.dart";
import "username/username.dart";

final Group accountCommand = Group(
  "account",
  "Account management commands.",
  children: [
    accessTokenCommand,
    exchangeCodeCommand,
    accountSettingsPageCommand,
    botDataCommand,
    accountReceiptsCommand,
    realNameCommand,
    usernameCommand,
  ],
  aliases: ["acc"],
  checks: [],
);
