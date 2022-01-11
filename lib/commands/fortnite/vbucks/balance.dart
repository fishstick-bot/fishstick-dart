import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
// import "package:fortnite/fortnite.dart";
import "package:numeral/numeral.dart";
import "../../../fishstick_dart.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../resources/emojis.dart";
import "../../../structures/privacy.dart";

final Command vbucksBalanceCommand = Command(
  "balance",
  "Get your or someone else's V-Bucks balance.",
  (
    Context ctx, [
    @Description("User to get V-Bucks balance for") IUser? user,
  ]) async {
    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();

    if (user != null) {
      dbUser = await client.database.getUser(user.id.toString());
      if (dbUser.linkedAccounts.isEmpty) {
        throw Exception("This user has no linked accounts.");
      }
      if (dbUser.privacyEnum == Privacy.private) {
        throw Exception("This user has set their privacy to private.");
      }
    }
    dbUser.fnClientSetup();

    await dbUser.fnClient.commonCore.init();

    final EmbedBuilder vBucksEmbed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = (user ?? ctx.user).username
        ..iconUrl = (user ?? ctx.user).avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title = "${dbUser.activeAccount.displayName}'s V-Bucks Balance"
      ..description =
          "Current V-Bucks Platform: **${dbUser.fnClient.commonCore.stats["current_mtx_platform"]}**\n\n**Overall - ${vbucks.emoji} ${Numeral(dbUser.fnClient.commonCore.totalVbucks).value()}**\n${dbUser.fnClient.commonCore.vbucksBreakdown.map((v) => "• **${Numeral(v.quantity).value()}** x ${v.platform} ${v.type}").toList().join("\n")}"
      ..timestamp = DateTime.now()
      ..footer = (EmbedFooterBuilder()
        ..text =
            "Total Purchased V-Bucks: ${Numeral(dbUser.fnClient.commonCore.totalVbucksPurchased).value()}");

    await ctx.respond(MessageBuilder.embed(vBucksEmbed));
  },
  hideOriginalResponse: false,
  checks: [],
);
