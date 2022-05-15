import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
// import "package:fortnite/fortnite.dart";
import "package:numeral/numeral.dart";
import "../../../fishstick_dart.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../resources/emojis.dart";
import "../../../structures/privacy.dart";

final ChatCommand vbucksBalanceCommand = ChatCommand(
  "balance",
  "Get your or someone else's V-Bucks balance.",
  id(
    "vbucks_balance_command",
    (
      IContext ctx, [
      @Description("User to get V-Bucks balance for") IUser? user,
      @Description("Get breakdown of V-Bucks purchases.")
          bool purchaseBreakdown = false,
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
        ..thumbnailUrl = dbUser.activeAccount.avatar
        ..description =
            "Current V-Bucks Platform: **${dbUser.fnClient.commonCore.currentMtxPlatform}**\n\n**Overall - ${vbucks.emoji} ${Numeral(dbUser.fnClient.commonCore.totalVbucks).value()}**\n${dbUser.fnClient.commonCore.vbucksBreakdown.map((v) => "• **${Numeral(v.quantity).value()}** x ${v.platform} ${v.type}").join("\n")}"
        ..timestamp = DateTime.now()
        ..footer = (EmbedFooterBuilder()
          ..text =
              "Total Purchased V-Bucks: ${Numeral(dbUser.fnClient.commonCore.totalVbucksPurchased).value()}");

      await ctx.respond(MessageBuilder.embed(vBucksEmbed));

      if (purchaseBreakdown == true &&
          dbUser.fnClient.commonCore.vbucksPurchased.keys.isNotEmpty) {
        vBucksEmbed
          ..title = "${dbUser.activeAccount.displayName}'s V-Bucks Purchases"
          ..description = dbUser.fnClient.commonCore.vbucksPurchased.keys
              .map((v) =>
                  "• **${dbUser.fnClient.commonCore.vbucksPurchased[v]}** x ${vbucks.emoji} ${Numeral(int.parse(v as String)).value()}")
              .join("\n");

        await ctx.respond(MessageBuilder.embed(vBucksEmbed));
      }
    },
  ),
  checks: [],
);
