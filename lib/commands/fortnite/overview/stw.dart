import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";
import "../../../extensions/string_extensions.dart";
import "../../../resources/emojis.dart";
import "../../../utils/utils.dart";

final Command overviewSTWCommand = Command(
  "stw",
  "View your save the world game mode profile overview.",
  (
    Context ctx, [
    @Description("The player to check profile for.") String? player,
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

    String fortEmoji(String stat) {
      switch (stat.toLowerCase()) {
        case "fortitude":
          return fortitude.emoji;

        case "resistance":
          return resistance.emoji;

        case "offense":
          return offense.emoji;

        case "tech":
        case "technology":
          return tech.emoji;

        default:
          return "";
      }
    }

    num accountLevel = campaign.accountLevel + campaign.pastMaxLevel;

    num backpackSize = campaign.backpackSize;
    num storageSize = campaign.storageSize;

    num researchPoints = campaign.researchPoints;

    final EmbedBuilder embed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title =
          "[${campaign.powerLevel.toStringAsFixed(1)}] $displayName | Save the World Overview"
      ..thumbnailUrl = player == null ? dbUser.activeAccount.avatar : null
      ..description = [
        "• Account level - ${accountLevel.toString().replaceAll(numberFormatRegex, ",").toBold()}",
        "• Backpack size - ${backpackSize.toString().toBold()}",
        "• Storage size - ${storageSize.toString().toBold()}",
        "• Zones Completed - ${campaign.matchesPlayed.toString().replaceAll(numberFormatRegex, ",").toBold()}",
        "• Collection book level - ${campaign.collectionBookLevel.toString().replaceAll(numberFormatRegex, ",").toBold()}",
        "• Unslot cost - ${vbucks.emoji} ${campaign.unslotCost.toString().replaceAll(numberFormatRegex, ",").toBold()}",
        "• FORT Stats - ${campaign.fortStats.keys.map((s) => "${fortEmoji(s)} ${campaign.fortStats[s].toString().replaceAll(numberFormatRegex, ",").toBold()}").join(" ")}",
        "• Research - ${(campaign.stats["research_levels"] as Map<String, dynamic>).keys.map((s) => "${fortEmoji(s)} ${(campaign.stats["research_levels"] as Map<String, dynamic>)[s].toString().replaceAll(numberFormatRegex, ",").toBold()}").join(" ")} ${research.emoji} ${researchPoints.toString().replaceAll(numberFormatRegex, ",").toBold()}",
      ].join("\n")
      ..timestamp = campaign.created
      ..footer = (EmbedFooterBuilder()..text = "Account created on")
      ..addField(
        name: "SSD Completions",
        content: campaign.completedStormShields.keys
            .map((s) =>
                "• $s - ${campaign.completedStormShields[s].toString().toBold()}")
            .join("\n"),
        inline: true,
      )
      ..addField(
        name: "Endurance Completions",
        content: campaign.enduranceCompletions.keys
            .map((e) =>
                "• $e - ${campaign.enduranceCompletions[e] != null ? "<t:${((campaign.enduranceCompletions[e]?.millisecondsSinceEpoch ?? 0) / 1000).round()}:d>" : "Not Completed".toBold()}")
            .join("\n"),
        inline: true,
      );

    await ctx.respond(MessageBuilder.embed(embed));
  },
  hideOriginalResponse: false,
  checks: [],
);
