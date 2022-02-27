import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../../../../database/database_user.dart";

import "../../../../extensions/context_extensions.dart";

final ChatCommand upgradeResearchCommand = ChatCommand(
  "upgrade",
  "Collect your save the world research points.",
  Id(
    "collect_research_command",
    (
      IContext ctx,
      @Choices({
        "Fortitude": "fortitude",
        "Resistance": "resistance",
        "Offense": "offense",
        "Tech": "technology",
      })
      @Description("The stat you want to upgrade.")
          String stat,
    ) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();

      final campaign = dbUser.fnClient.campaign;

      await campaign.upgradeResearchStat(stat);

      final EmbedBuilder embed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title =
            "${dbUser.activeAccount.displayName} | Save the World Researcg"
        ..thumbnailUrl = dbUser.activeAccount.avatar
        ..description = "Successfully upgraded **$stat**."
        ..timestamp = DateTime.now();

      await ctx.respond(MessageBuilder.embed(embed));
    },
  ),
  checks: [],
);
