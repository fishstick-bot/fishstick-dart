import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../fishstick_dart.dart";
import "../../../../resources/emojis.dart";

final ChatCommand externalUnlinkCommand = ChatCommand(
  "unlink",
  "Unlink an account external auth connection.",
  (
    IContext ctx,
    @Description("External auth platform that you want to unlink.")
        String platform,
  ) async {
    DatabaseUser user = await ctx.dbUser;
    user.fnClientSetup();

    final externalAuths = await user.fnClient.auth.getExternalAuths();
    if (externalAuths.isEmpty) {
      throw Exception("You don't have any external auths.");
    }

    var confirmationMsg = await ctx.takeConfirmation(
        "Are you sure you want to unlink $platform from your external auths?");
    if (confirmationMsg == null) {
      return null;
    }

    await user.fnClient.auth.unlinkExternalAuth(platform: platform);

    var externalAuthNames = {
      "google": "Google",
      "github": "GitHub",
      "psn": "PlayStation Network",
      "xbl": "Xbox Live",
    };

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
            ..title = "${user.activeAccount.displayName} | External Auths"
            ..thumbnailUrl = user.activeAccount.avatar
            ..description =
                "${tick.emoji} Successfully unlinked ${externalAuthNames[platform] ?? platform.toUpperCase()} from your account's external auths.",
        ],
    );
  },
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [],
);
