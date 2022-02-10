import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../../../fishstick_dart.dart";

import "../../../../database/database_user.dart";

import "../../../../extensions/context_extensions.dart";
import "../../../../extensions/string_extensions.dart";

import "../../../../resources/emojis.dart";

final ChatCommand mskCommand = ChatCommand(
  "msk",
  "View your save the world game mode mythic storm king quest.",
  (
    IContext ctx, [
    @Description("The player to check quest for.") String? player,
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

    var quest = campaign.stormKingQuest;
    var schematics = {};

    Map<String, String> emojis = {
      "blunt_hammer_stormking": stormkingsfury.emoji,
      "explosive_stormking": stormkingswrath.emoji,
      "assault_stormking": stormkingsscourge.emoji,
      "edged_sword_stormking": stormkingsravager.emoji,
      "pistol_stormking": stormkingsonslaught.emoji,
    };

    for (final s in campaign.stormKingSchematicsCount.keys) {
      List<String> schematicNameList = s.split(":").last.split("_")
        ..removeLast()
        ..removeLast()
        ..removeLast()
        ..removeAt(0);
      String schematicName = schematicNameList.join("_");
      schematics[emojis[schematicName] ?? schematicName] =
          (schematics[schematicName] ?? 0) +
              campaign.stormKingSchematicsCount[s];
    }

    final EmbedBuilder embed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title =
          "[${campaign.powerLevel.toStringAsFixed(1)}] $displayName | Mythic Storm King Quest"
      ..thumbnailUrl = player == null ? dbUser.activeAccount.avatar : null
      ..description =
          "• Name - ${quest.name.toBold()}\n• Description - ${quest.description.toBold()}\n• Completion - **${quest.completionCurrent}/${quest.completionTarget}**"
      ..addField(
        name: "Mythic Schematics",
        content: campaign.stormKingSchematicsCount.keys.isEmpty
            ? "None"
            : schematics.keys
                .map((s) => "${schematics[s].toString().toBold()} $s")
                .join(" "),
      )
      ..timestamp = DateTime.now()
      ..footer = (EmbedFooterBuilder()..text = client.footerText);

    await ctx.respond(MessageBuilder.embed(embed));
  },
  checks: [],
  aliases: ["stormking"],
);
