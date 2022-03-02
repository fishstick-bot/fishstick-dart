import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../extensions/context_extensions.dart";
import "../../../fishstick_dart.dart";
import "../../../utils/utils.dart";

final ChatCommand brBuyCommand = ChatCommand(
  "br",
  "Buy from fortnite battle royale item shop.",
  Id(
    "br_buy_command",
    (IContext ctx, int index) async {
      final dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();

      index = index - 1;
      if (index < 0 ||
          index >
              client
                  .systemJobs.catalogManagerSystemJob.brCatalog.items.length) {
        throw Exception(
            "Invalid item index. Expected value between 1 and ${client.systemJobs.catalogManagerSystemJob.brCatalog.items.length}");
      }

      final item =
          client.systemJobs.catalogManagerSystemJob.brCatalog.items[index];

      await dbUser.fnClient.commonCore.init();

      if (item.finalPrice > dbUser.fnClient.commonCore.totalVbucks) {
        throw Exception(
            "You don't have enough V-Bucks to buy this item. Required ${item.finalPrice} V-Bucks but you have ${dbUser.fnClient.commonCore.totalVbucks} V-Bucks.");
      }

      IMessage? msg = await ctx.takeConfirmation(
          "Are you sure you want to buy ${item.name} for ${item.finalPrice} V-Bucks?");

      if (msg == null) {
        return;
      }

      await purchaseCatalogEntry(
        item.offerId,
        client: dbUser.fnClient,
        expectedTotalPrice: item.finalPrice,
      );

      await msg.edit(
        MessageBuilder.content(
          "Successfully purchased ${item.name} for ${item.finalPrice} V-Bucks.",
        ),
      );
    },
  ),
);
