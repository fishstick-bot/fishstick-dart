import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../fishstick_dart.dart";

final ChatCommand usernameChangeCommand = ChatCommand(
  "change",
  "Change your account username.",
Id("username_change_command",
  (
    IContext ctx,
    @Description("What would you like your new username as?") String update,
  ) async {
    DatabaseUser user = await ctx.dbUser;
    user.fnClientSetup();

    final accountInfo = await user.fnClient.auth.getAccountInfo();

    if (!accountInfo.canUpdateDisplayName) {
      throw Exception("You cannot change your username right now.");
    }

    var confirmationMsg = await ctx.takeConfirmation(
        "Are you sure you want to update your display name from **${accountInfo.displayName}** to **$update**.");
    if (confirmationMsg == null) {
      return null;
    }

    await user.fnClient.auth.updateAccountInfo({
      "displayName": update,
    });

    return await confirmationMsg.edit(
      ComponentMessageBuilder()
        ..embeds = [
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
                "Successfully updated display name from **${accountInfo.displayName}** to **$update**.",
        ]
        ..componentRows = [],
    );
  },
),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [],
);
