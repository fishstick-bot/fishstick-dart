import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../../../database/database_user.dart";

import "../../../extensions/context_extensions.dart";

import "../../../resources/items.dart";

import "../../../utils/utils.dart";

final ChatCommand resourcesSTWCommand = ChatCommand(
  "resources",
  "View your save the world game mode profile resources.",
  Id(
    "resources_stwcommand",
    (
      IContext ctx, [
      @Description("The player to check resources for.") String? player,
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

      var resources = campaign.accountResources;

      var img = await drawSTWResources(
        resources: resources.map((r) {
          var resource = allItems.firstWhere(
              (i) => i.id.toLowerCase().contains(r.resourceId.toLowerCase()));
          return {
            "name": resource.name,
            "quantity": r.quantityString,
            "rarity": resource.rarity,
            "image": resource.id,
          };
        }).toList(),
        epicname: displayName,
        username: ctx.user.tag,
      );

      final EmbedBuilder embed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title =
            "[${campaign.powerLevel.toStringAsFixed(1)}] $displayName | Save the World Resources"
        ..thumbnailUrl = player == null ? dbUser.activeAccount.avatar : null
        ..imageUrl = "attachment://resources.png"
        ..timestamp = campaign.created
        ..footer = (EmbedFooterBuilder()..text = "Account created on");

      await ctx.respond(MessageBuilder.embed(embed)
        ..addAttachment(AttachmentBuilder.bytes(img, "resources.png")));
    },
  ),
  checks: [],
);
