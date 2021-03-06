import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../fishstick_dart.dart";
import "../../../../resources/emojis.dart";

final ChatCommand realNameLastCommand = ChatCommand(
  "last",
  "Update your account last name.",
  id(
    "real_name_last_command",
    (
      IContext ctx,
      @Description("What would you like your real last name to?") String update,
    ) async {
      DatabaseUser user = await ctx.dbUser;
      user.fnClientSetup();

      final accountInfo = await user.fnClient.auth.getAccountInfo();

      var confirmationMsg = await ctx.takeConfirmation(
          "Are you sure you want to update your real name from **${accountInfo.name} ${accountInfo.lastName}** to **${accountInfo.name} $update**?");
      if (confirmationMsg == null) {
        return null;
      }

      await user.fnClient.auth.updateAccountInfo({
        "lastName": update,
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
              ..title = "${user.activeAccount.displayName} | Real Name"
              ..thumbnailUrl = user.activeAccount.avatar
              ..description =
                  "${tick.emoji} Successfully updated your real name from **${accountInfo.name} ${accountInfo.lastName}** to **${accountInfo.name} $update**.",
          ],
      );
    },
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [],
);
