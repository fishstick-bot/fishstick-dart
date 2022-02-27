import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../../../../database/database_user.dart";

import "../../../../extensions/context_extensions.dart";

final ChatCommand collectResearchCommand = ChatCommand(
  "collect",
  "Collect your save the world research points.",
  Id(
    "collect_research_command",
    (IContext ctx) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();

      final campaign = dbUser.fnClient.campaign;
      await campaign.init(dbUser.fnClient.accountId);

      await campaign.collectResearchPoints();

      final EmbedBuilder embed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title =
            "${dbUser.activeAccount.displayName} | Save the World Researcg"
        ..thumbnailUrl = dbUser.activeAccount.avatar
        ..description = "Successfully collected research points."
        ..timestamp = DateTime.now();

      await ctx.respond(MessageBuilder.embed(embed));
    },
  ),
  checks: [],
);
