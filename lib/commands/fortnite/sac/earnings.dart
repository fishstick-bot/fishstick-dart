import "package:fishstick_dart/utils/utils.dart";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";

final ChatCommand affiliateEarningsCommand = ChatCommand(
  "earnings",
  "Get your SAC earnings.",
  id(
    "sac_earnings_command",
    (IContext ctx) async {
      DatabaseUser user = await ctx.dbUser;
      user.fnClientSetup();

      await user.fnClient.commonCore
          .init(); // just to make sure token is valid.
      final res = await webApiRequest(
        "https://www.epicgames.com/affiliate/api/v2/get-earnings-data?version=2",
        user.fnClient.session,
      );

      if (res["success"] == false) {
        throw Exception(res["data"] ?? "Unknown error.");
      }

      final data = res["data"];

      return await ctx.respond(
        MessageBuilder.embed(
          EmbedBuilder()
            ..author = (EmbedAuthorBuilder()
              ..name = (ctx.user).username
              ..iconUrl = (ctx.user).avatarURL(format: "png"))
            ..color = DiscordColor.fromHexString(user.color)
            ..title = "${user.activeAccount.displayName}'s SAC Earnings"
            ..thumbnailUrl = user.activeAccount.avatar
            ..timestamp = DateTime.now()
            ..addField(
              name: "Unpaid Earnings",
              content:
                  "${data["eligibleEarnings"]} ${data["eligibleEarningsCurrency"]}",
            )
            ..addField(
              name: "Last Payout",
              content: data["lastPayoutDate"] != null
                  ? "${data["lastPayout"]} ${data["lastPayoutCurrency"]} - ${data["lastPayoutDate"]}"
                  : "None",
            )
            ..addField(
              name: "Lifetime Earnings",
              content:
                  "${data["lifetimePayouts"]} ${data["lifetimePayoutsCurrency"]}",
            ),
        ),
        private: true,
      );
    },
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [premiumCheck],
);
