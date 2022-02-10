import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";
import "../../../extensions/string_extensions.dart";
import "../../../resources/emojis.dart";
import "../../../utils/utils.dart";

final ChatCommand overviewBRCommand = ChatCommand(
  "br",
  "View your battle royale game mode profile overview.",
  Id(
    "br_overview_command",
    (IContext ctx) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();
      final athena = dbUser.fnClient.athena;

      await Future.wait([athena.init(), athena.getGold()]);

      final EmbedBuilder embed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title = "${dbUser.activeAccount.displayName} | Battle Royale Overview"
        ..thumbnailUrl = dbUser.activeAccount.avatar
        ..description =
            "• Account level - **${athena.accountLevel.toString().toBold()}**"
        ..timestamp = athena.lastMatch
        ..footer = (EmbedFooterBuilder()..text = "Last match end")
        ..addField(
          name: "Season ${athena.seasonNumber} Info",
          content:
              "• ${athena.isVIP ? "Battle" : "Free"} pass level - ${athena.battlePassLevel.toString().toBold()}",
        )
        ..addField(
          name: "Supercharged XP",
          content:
              "• XP - **${athena.superchargedXP.toString().replaceAll(numberFormatRegex, ",")} / 162,000**\n• Multiplier - ${athena.superchargedXPMultiplier.toString().toBold()}\n• Exchange - ${athena.superchargedXPExchange.toString().toBold()}\n• Overflow - ${athena.overflowedSuperchargedXP.toString().replaceAll(numberFormatRegex, ",").toBold()}",
        )
        ..addField(
          name: "Seasonal Resources",
          content:
              "• ${star.emoji} Battle Stars - **${athena.battlestars} (Total - ${athena.battlestarsSeasonTotal})**\n• ${bars.emoji} Gold - ${athena.gold.toString().replaceAll(numberFormatRegex, ",").toBold()}",
        );

      await ctx.respond(MessageBuilder.embed(embed));
    },
  ),
  checks: [],
);
