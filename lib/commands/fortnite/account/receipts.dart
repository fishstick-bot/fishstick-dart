import "dart:convert";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
// import "package:fortnite/fortnite.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";
import "../../../utils/utils.dart";

final ChatCommand accountReceiptsCommand = ChatCommand(
  "receipts",
  "Gives your account purchase receipts in a file.",
  (IContext ctx) async {
    DatabaseUser user = await ctx.dbUser;
    user.fnClientSetup();

    await user.fnClient.commonCore.init();

    return await ctx.respond(
      ComponentMessageBuilder()
        ..content = "Account receipts for ${user.fnClient.displayName}."
        ..addBytesAttachment(
          utf8.encode(JsonEncoder.withIndent(" " * 4)
              .convert(user.fnClient.commonCore.receipts)
              .toString()),
          "receipts.txt",
        ),
      private: true,
    );
  },
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [premiumCheck],
);
