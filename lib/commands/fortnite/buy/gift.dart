import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../extensions/context_extensions.dart";
import "../../../fishstick_dart.dart";
import "../../../utils/utils.dart";

final ChatCommand giftCommand = ChatCommand(
  "gift",
  "Gift from fortnite battle royale item shop.",
  Id(
    "gift_command",
    (
      IContext ctx,
      @Description("Name of friend you want to gift to.") String friend,
      int index, [
      @Description("The gift message.") String? message,
    ]) async {
      final dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();

      var search = await dbUser.fnClient.findPlayers(friend);
      if (search.isEmpty) {
        throw Exception("No players found with prefix: $friend.");
      }

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
            "You don't have enough V-Bucks to gift this item. Required ${item.finalPrice} V-Bucks but you have ${dbUser.fnClient.commonCore.totalVbucks} V-Bucks.");
      }

      IMessage? msg = await ctx.takeConfirmation(
          "Are you sure you want to gift ${item.name} to $friend (${search.first.accountId}) for ${item.finalPrice} V-Bucks?");

      if (msg == null) {
        return;
      }

      await giftCatalogEntry(
        item.offerId,
        [search.first.accountId],
        client: dbUser.fnClient,
        expectedTotalPrice: item.finalPrice,
        message: message,
      );

      await msg.edit(
        MessageBuilder.content(
          "Successfully gifted ${item.name} to $friend for ${item.finalPrice} V-Bucks.",
        ),
      );
    },
  ),
);
