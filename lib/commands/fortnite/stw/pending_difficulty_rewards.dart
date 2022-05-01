import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../../../fishstick_dart.dart";

import "../../../database/database_user.dart";

import "../../../extensions/context_extensions.dart";
import "../../../extensions/string_extensions.dart";

import "../../../utils/utils.dart";

final ChatCommand pendingDifficultyRewardsCommand = ChatCommand(
  "difficultyrewards",
  "View your unclaimed save the world game mode difficulty rewards.",
  Id(
    "pending_difficulty_rewards_command",
    (
      IContext ctx, [
      @Autocomplete(findPlayerSuggestions)
      @Description("The player to check unclaimed rewards for.")
          String? player,
    ]) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();
      final campaign = dbUser.fnClient.campaign;

      String displayName = dbUser.fnClient.displayName;
      String accountId = dbUser.fnClient.accountId;

      if (player != null) {
        var search = await dbUser.fnClient.findPlayers(player);
        if (search.isEmpty) {
          throw Exception("No players found with prefix: $player.");
        }

        displayName = search.first.displayName;
        accountId = search.first.accountId;
      }

      await campaign.init(accountId);

      if (!campaign.tutorialCompleted) {
        throw Exception(
            "$displayName haven't completed the tutorial yet. Please complete the tutorial before using this command.");
      }

      var pending = campaign.pendingDifficultyRewards.map(
          (key, value) => MapEntry(key.split(":").last.toLowerCase(), value));

      if (pending.keys.isEmpty) {
        throw Exception("$displayName has no unclaimed difficulty rewards.");
      }

      final EmbedBuilder embed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title =
            "[${campaign.powerLevel.toStringAsFixed(1)}] $displayName | Pending Difficulty Rewards"
        ..thumbnailUrl = player == null ? dbUser.activeAccount.avatar : null
        ..description = pending.keys
            .map((r) => "• $r - ${pending[r].toString().toBold()}")
            .join("\n")
        ..timestamp = DateTime.now()
        ..footer = (EmbedFooterBuilder()..text = client.footerText);

      await ctx.respond(MessageBuilder.embed(embed));
    },
  ),
  checks: [],
  aliases: ["di"],
);
