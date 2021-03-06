import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../../../../database/database_user.dart";

import "../../../../extensions/context_extensions.dart";

import "../../../../utils/utils.dart";

final ChatCommand backpackAndStorageInventoryCommand = ChatCommand(
  "backpack-and-storage",
  "View your STW backpack.",
  id(
    "backpack_and_storage_inventory_command",
    (
      IContext ctx, [
      bool raw = false,
    ]) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();

      await Future.wait([
        dbUser.fnClient.campaign.storage.init(),
        dbUser.fnClient.campaign.backpack.init(),
      ]);
      var inventory = dbUser.fnClient.campaign.backpack;
      var inventory2 = dbUser.fnClient.campaign.storage;

      var _items = [
        ...inventory.ingredients.map((i) => {
              "id": i.templateId.split(":").last,
              "quantity": i.quantity,
              "pl": null,
            }),
        ...inventory2.ingredients.map((i) => {
              "id": i.templateId.split(":").last,
              "quantity": i.quantity,
              "pl": null,
            }),
        ...inventory.traps.map((i) => {
              "id": i.templateId.split(":").last,
              "quantity": i.quantity,
              "pl": i.rating,
            }),
        ...inventory2.traps.map((i) => {
              "id": i.templateId.split(":").last,
              "quantity": i.quantity,
              "pl": i.rating,
            }),
        ...inventory.weapons.map((i) => {
              "id": i.templateId.split(":").last,
              "quantity": i.quantity,
              "pl": i.rating,
            }),
        ...inventory2.weapons.map((i) => {
              "id": i.templateId.split(":").last,
              "quantity": i.quantity,
              "pl": i.rating,
            }),
        ...inventory.worldItems.map((i) => {
              "id": i.templateId.split(":").last,
              "quantity": i.quantity,
              "pl": null,
            }),
        ...inventory2.worldItems.map((i) => {
              "id": i.templateId.split(":").last,
              "quantity": i.quantity,
              "pl": null,
            }),
      ];

      Map<String, Map<String, dynamic>> items = {};

      for (final item in _items) {
        if (item["id"] == "edittool" ||
            item["id"].toString().contains("buildingitemdata")) {
          continue;
        }
        if (items[item["id"]] == null) {
          items[item["id"].toString()] = item;
        } else {
          items[item["id"]]!["quantity"] += item["quantity"];
        }
      }

      var img = await drawSTWInventory(
        items: items.values.toList(),
        username: ctx.user.tag,
        epicname: dbUser.fnClient.displayName,
        raw: raw,
      );

      final EmbedBuilder embed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title =
            "${dbUser.fnClient.displayName} | Save the World Inventory - Backpack and Storage"
        ..imageUrl = "attachment://inventory.png"
        ..timestamp = DateTime.now();

      await ctx.respond(MessageBuilder.embed(embed)
        ..addAttachment(AttachmentBuilder.bytes(img, "inventory.png")));
    },
  ),
  checks: [],
);
