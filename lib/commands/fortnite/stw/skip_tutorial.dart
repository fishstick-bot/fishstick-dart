import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../resources/emojis.dart";

final ChatCommand skipTutorialCommand = ChatCommand(
  "skip-tutorial",
  "Skip your save the world gamemode tutorial.",
  (IContext ctx) async {
    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();
    final campaign = dbUser.fnClient.campaign;

    await campaign.init(dbUser.activeAccount.accountId);
    await campaign.skipTutorial();

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
  checks: [],
);
