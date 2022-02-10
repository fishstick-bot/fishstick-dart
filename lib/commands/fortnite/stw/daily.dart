import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../../../../database/database_user.dart";

import "../../../../extensions/context_extensions.dart";

final ChatCommand claimDailyCommand = ChatCommand(
  "claim-daily",
  "Claim your save the world game mode daily login rewards.",
  (IContext ctx) async {
    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();
    final campaign = dbUser.fnClient.campaign;

    var claimed = await campaign.claimDailyReward();

    var todaysReward = claimed.rewardsByDay.removeAt(0);
    int index = 0;

    final EmbedBuilder embed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title =
          "${dbUser.activeAccount.displayName} | Save the World Daily Rewards"
      ..thumbnailUrl = dbUser.activeAccount.avatar
      ..description = claimed.alreadyClaimed
          ? "You have already claimed todays reward."
          : "Successfully claimed todays reward."
      ..timestamp = DateTime.now()
      ..fields.addAll([
        EmbedFieldBuilder(
          "Today's Reward",
          "Day ${claimed.daysLoggedIn} - **${todaysReward.amount}x ${todaysReward.name}**",
        ),
        EmbedFieldBuilder(
          "Upcoming Rewards",
          claimed.rewardsByDay.map((reward) {
            index++;
            return "Day ${claimed.daysLoggedIn + index} - **${reward.amount}x ${reward.name}**";
          }).join("\n"),
        ),
      ]);

    await ctx.respond(MessageBuilder.embed(embed));
  },
  checks: [],
);
