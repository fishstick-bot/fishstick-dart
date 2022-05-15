import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../fishstick_dart.dart";

final ChatCommand usernameViewCommand = ChatCommand(
  "view",
  "View your account username information.",
  id(
    "username_view_command",
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
            ..title = "${user.activeAccount.displayName} | Username"
            ..thumbnailUrl = user.activeAccount.avatar
            ..description =
                "Display Name: **${accountInfo.displayName}**\nLast display name update: **${DateTime.parse(accountInfo.lastDisplayNameChange).toString().split(" ")[0]}**\nNumber of display name changes: **${accountInfo.numberOfDisplayNameChanges}**\n\n${accountInfo.canUpdateDisplayName ? "You can change your display name with:\n• /account username change **AABBCCDDEEFF**" : "You can not update display name right now."}",
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
