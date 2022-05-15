import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../fishstick_dart.dart";

final ChatCommand realNameViewCommand = ChatCommand(
  "view",
  "View your account real name information.",
  id(
    "real_name_view_command",
    (IContext ctx) async {
      DatabaseUser user = await ctx.dbUser;
      user.fnClientSetup();

      final accountInfo = await user.fnClient.auth.getAccountInfo();

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
                "Real Name: **${accountInfo.name} ${accountInfo.lastName}**\n\nYou can change your display name with:\n• /account realname first | last **AABBCCDDEEFF**",
        ),
        private: true,
      );
    },
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [],
);
