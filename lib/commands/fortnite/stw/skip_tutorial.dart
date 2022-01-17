import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../resources/emojis.dart";

final Command skipTutorialCommand = Command(
  "skip-tutorial",
  "Skip your save the world gamemode tutorial.",
  (Context ctx) async {
    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();
    final campaign = dbUser.fnClient.campaign;

    await campaign.init(dbUser.activeAccount.accountId);

    if (campaign.tutorialCompleted) {
      throw Exception(
          "You have already completed the tutorial. You can't skip it again.");
    }

    final EmbedBuilder embed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title =
          "[${campaign.powerLevel.toStringAsFixed(1)}] ${dbUser.activeAccount.displayName} | Save the World Tutorial"
      ..thumbnailUrl = dbUser.activeAccount.avatar
      ..description = "${tick.emoji} Successfully skipped the tutorial."
      ..timestamp = campaign.created
      ..footer = (EmbedFooterBuilder()..text = "Account created on");

    await ctx.respond(MessageBuilder.embed(embed));
  },
  hideOriginalResponse: false,
  checks: [],
);
