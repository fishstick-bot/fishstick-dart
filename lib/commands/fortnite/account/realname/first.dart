import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../fishstick_dart.dart";
import "../../../../resources/emojis.dart";

final Command realNameFirstCommand = Command(
  "first",
  "Update your account first name.",
  (
    Context ctx,
    @Description("What would you like your real first name to?") String update,
  ) async {
    DatabaseUser user = await ctx.dbUser;
    user.fnClientSetup();

    final accountInfo = await user.fnClient.auth.getAccountInfo();
    await user.fnClient.auth.updateAccountInfo({
      "first": update,
    });

    return await ctx.respond(
      MessageBuilder.embed(
        EmbedBuilder()
          ..author = (EmbedAuthorBuilder()
            ..name = ctx.user.username
            ..iconUrl = ctx.user.avatarURL(format: "png"))
          ..color = DiscordColor.fromHexString(user.color)
          ..footer = (EmbedFooterBuilder()..text = client.footerText)
          ..timestamp = DateTime.now()
          ..title = "${user.activeAccount.displayName} | Real Name"
          ..thumbnailUrl = user.activeAccount.avatar
          ..description =
              "${tick.emoji} Successfully updated your real name from **${accountInfo.name} ${accountInfo.lastName} to **$update ${accountInfo.lastName}**.",
      ),
      private: true,
    );
  },
  hideOriginalResponse: true,
  checks: [],
);
