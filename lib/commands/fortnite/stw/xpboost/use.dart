import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "package:fortnite/fortnite.dart";

import "../../../../database/database_user.dart";

import "../../../../extensions/context_extensions.dart";

final ChatCommand useXpBoostCommand = ChatCommand(
  "use",
  "Use your STW XP boosts.",
  id(
    "use_xp_boost_command",
    (
      IContext ctx,
      @Description("The amount of XP boosts to use") int quantity,
    ) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();
      final campaign = dbUser.fnClient.campaign;
      await campaign.init(dbUser.fnClient.accountId);

      var target = campaign.items
          .where((i) => i.templateId == "ConsumableAccountItem:smallxpboost");

      if (target.isEmpty) {
        throw Exception("You don't have any XP boosts.");
      }

      if (quantity > target.first.quantity) {
        throw Exception(
            "You don't have that many XP boosts. Found ${target.first.quantity}, but quantity provided was $quantity.");
      }

      final EmbedBuilder embed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title =
            "${dbUser.activeAccount.displayName} | Save the World XP Boosts"
        ..thumbnailUrl = dbUser.activeAccount.avatar
        ..description = "Using $quantity XP Boosts..."
        ..timestamp = DateTime.now();

      var msg = await ctx.respond(MessageBuilder.embed(embed));

      int left = quantity;
      for (int i = 0; i < quantity; i += 3) {
        await Future.wait(
          List.generate(
            target.first.quantity < 3 ? target.first.quantity : 3,
            (i) => dbUser.fnClient.post(
              MCP(FortniteProfile.campaign,
                      accountId: dbUser.fnClient.accountId)
                  .ActivateConsumable,
              body: {
                "targetItemId": target.first.id,
              },
            ),
          ),
        );
        target.first.quantity -= 3;
        left -= 3;

        await msg.edit(MessageBuilder.embed(
            embed..description = "Using $left XP Boosts..."));
      }

      await msg.edit(MessageBuilder.embed(
          embed..description = "Done! used $left XP Boosts."));
    },
  ),
  checks: [],
);
