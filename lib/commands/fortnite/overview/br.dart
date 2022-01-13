import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";
import "../../../extensions/string_extensions.dart";
import "../../../resources/emojis.dart";
import "../../../utils/utils.dart";

final Command overviewBRCommand = Command(
  "br",
  "View your battle royale game mode profile overview.",
  (Context ctx) async {
    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();

    await Future.wait([
      dbUser.fnClient.athena.init(),
      dbUser.fnClient.athena.getGold(),
    ]);

    final EmbedBuilder embed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title = "${dbUser.activeAccount.displayName} | Battle Royale Overview"
      ..thumbnailUrl = dbUser.activeAccount.avatar
      ..description =
          "• Account level - **${dbUser.fnClient.athena.accountLevel.toString().toBold()}**"
      ..timestamp = dbUser.fnClient.athena.lastMatch
      ..footer = (EmbedFooterBuilder()..text = "Last match end")
      ..addField(
        name: "Season ${dbUser.fnClient.athena.seasonNumber} Info",
        content:
            "• ${dbUser.fnClient.athena.isVIP ? "Battle" : "Free"} pass level - ${dbUser.fnClient.athena.battlePassLevel.toString().toBold()}",
      )
      ..addField(
        name: "Supercharged XP",
        content:
            "• XP - **${dbUser.fnClient.athena.superchargedXP.toString().replaceAll(numberFormatRegex, ",")} / 162,000**\n• Multiplier - ${dbUser.fnClient.athena.superchargedXPMultiplier.toString().toBold()}\n• Exchange - ${dbUser.fnClient.athena.superchargedXPExchange.toString().toBold()}\n• Overflow - ${dbUser.fnClient.athena.overflowedSuperchargedXP.toString().replaceAll(numberFormatRegex, ",").toBold()}",
      )
      ..addField(
        name: "Seasonal Resources",
        content:
            "• ${star.emoji} Battle Stars - **${dbUser.fnClient.athena.battlestars} (Total - ${dbUser.fnClient.athena.battlestarsSeasonTotal})**\n• ${bars.emoji} Gold - ${dbUser.fnClient.athena.gold.toString().replaceAll(numberFormatRegex, ",").toBold()}",
      );

    await ctx.respond(MessageBuilder.embed(embed));
  },
  hideOriginalResponse: false,
  checks: [],
);
