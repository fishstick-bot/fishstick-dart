import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../database/database_user.dart";
import "../../../structures/epic_account.dart";
import "../../../extensions/context_extensions.dart";
import "../../../utils/utils.dart";

final ChatCommand beeacCommand = ChatCommand(
  "be-eac",
  "Tells if your account's are Battle Eye or Easy Anti Cheat.",
  Id(
    "be-eac_command",
    (IContext ctx) async {
      final DatabaseUser user = await ctx.dbUser;

      Map<String, bool> beeac = {};

      Future<void> doOnAcc(EpicAccount a) async {
        beeac[a.displayName] = await isEAC(user.fnClientSetup(a.accountId));
      }

      await Future.wait(user.linkedAccounts.map(doOnAcc));

      await ctx.respond(
        MessageBuilder.embed(
          EmbedBuilder()
            ..author = (EmbedAuthorBuilder()
              ..name = ctx.user.username
              ..iconUrl = ctx.user.avatarURL(format: "png"))
            ..color = DiscordColor.fromHexString(user.color)
            ..title = "Battle Eye or Easy Anti Cheat"
            ..description = beeac.keys
                .map((a) => beeac[a] == false
                    ? "• **$a** - Battle Eye"
                    : "• **$a** - Easy Anti Cheat")
                .join("\n")
            ..timestamp = DateTime.now(),
        ),
      );
    },
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [],
);
