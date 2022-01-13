import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_user.dart";
import "../../extensions/context_extensions.dart";
import "../../resources/emojis.dart";
import "../../utils/utils.dart";

final Command afkCommand = Command(
  "afk",
  "Get your afk creative progress.",
  (Context ctx) async {
    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();

    await dbUser.fnClient.athena.init();

    if (dbUser.fnClient.athena.creativeAFKTimePlayed ==
        dbUser.fnClient.athena.maxCreativeAFKTimePlayable) {
      throw Exception(
          "You have already claimed max afk creative xp claimable for today.");
    }

    final EmbedBuilder embed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title = "${dbUser.activeAccount.displayName}'s AFK Creative Progress"
      ..thumbnailUrl = dbUser.activeAccount.avatar
      ..description =
          "${ctx.createProgressBar(dbUser.fnClient.athena.creativeAFKTimePlayed / dbUser.fnClient.athena.maxCreativeAFKTimePlayable)}\n• ${dbUser.fnClient.athena.creativeAFKTimePlayed} / ${dbUser.fnClient.athena.maxCreativeAFKTimePlayable} minutes played\n• ${dbUser.fnClient.athena.xpClaimedFromAFKCreative.toString().replaceAll(numberFormatRegex, ",")} / ${dbUser.fnClient.athena.maxAFKCreativeXPPerDay.toString().replaceAll(numberFormatRegex, ",")} ${seasonxp.emoji}"
      ..timestamp = dbUser.fnClient.athena.lastCreativeAFKTimeGranted
      ..footer = (EmbedFooterBuilder()..text = "Last grant");

    await ctx.respond(MessageBuilder.embed(embed));
  },
  hideOriginalResponse: false,
  checks: [],
  aliases: ["cxp"],
);
