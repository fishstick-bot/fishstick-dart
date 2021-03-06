import "package:nyxx_commands/nyxx_commands.dart";
import "token/token.dart";
import "exchange_code/exchange_code.dart";
import "page.dart";
// import "botdata.dart";
import "receipts.dart";
import "realname/realname.dart";
import "username/username.dart";
import "external/external.dart";
import "authcode.dart";

final ChatGroup accountCommand = ChatGroup(
  "account",
  "Account management commands.",
  children: [
    accessTokenCommand,
    exchangeCodeCommand,
    accountSettingsPageCommand,
    // botDataCommand,
    accountReceiptsCommand,
    realNameCommand,
    usernameCommand,
    externalsCommand,
    authcodeCommand,
  ],
  aliases: ["acc"],
  checks: [],
);
