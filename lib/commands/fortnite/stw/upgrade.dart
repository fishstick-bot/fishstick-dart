import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:fishstick_dart/fishstick_dart.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../resources/emojis.dart";

final ChatCommand stwUpgradeCommand = ChatCommand(
  "upgrade",
  "Upgrade a save the world homebase node..",
  Id(
    "stw_upgrade_command",
    (
      IContext ctx,
      @Choices({
        "Backpack": "HomebaseNode:skilltree_backpacksize",
        "Storage": "HomebaseNode:skilltree_stormshieldstorage",
      })
      @Description("Homebase node to upgrade.")
          String nodeId,
    ) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();
      final campaign = dbUser.fnClient.campaign;

      await campaign.init(dbUser.activeAccount.accountId);
      await campaign.upgradeHomebaseNode(nodeId);

      final EmbedBuilder embed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title =
            "[${campaign.powerLevel.toStringAsFixed(1)}] ${dbUser.activeAccount.displayName} | Save the World Upgrade"
        ..thumbnailUrl = dbUser.activeAccount.avatar
        ..description = "${tick.emoji} Upgraded $nodeId."
        ..timestamp = DateTime.now()
        ..footer = (EmbedFooterBuilder()..text = client.footerText);

      await ctx.respond(MessageBuilder.embed(embed));
    },
  ),
  checks: [],
);
