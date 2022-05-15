import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../fishstick_dart.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";

final ChatCommand affiliateChangeCommand = ChatCommand(
  "change",
  "Change your supported creator in the item shop.",
  id(
    "affiliate_change_command",
    (
      IContext ctx,
      @Description("The creator to support.") String creator,
    ) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();
      await dbUser.fnClient.commonCore.init();
      await dbUser.fnClient.commonCore.setSupportedCreator(creator);

      final EmbedBuilder embed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title = "${dbUser.activeAccount.displayName}'s Supported Creator"
        ..description = dbUser.fnClient.commonCore.supportedCreator.isEmpty
            ? "You are now supporting: **$creator**."
            : "Successfully updated supported creator from **${dbUser.fnClient.commonCore.supportedCreator}** to **$creator**."
        ..timestamp = DateTime.now()
        ..footer = (EmbedFooterBuilder()..text = client.footerText);

      await ctx.respond(MessageBuilder.embed(embed));
    },
  ),
  checks: [],
);
