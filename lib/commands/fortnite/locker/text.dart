import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:nyxx_pagination/nyxx_pagination.dart";

import "package:fortnite/fortnite.dart";

import "package:random_string/random_string.dart";

import "../../../fishstick_dart.dart";

import "../../../database/database_user.dart";

import "../../../extensions/context_extensions.dart";
import "../../../extensions/string_extensions.dart";
import "../../../extensions/fortnite_extensions.dart";

import "../../../resources/emojis.dart";

final Command lockerTextCommand = Command(
  "text",
  "View your locker in a text-based format.",
  (Context ctx) async {
    if (client.cachedCosmetics.isEmpty) {
      throw Exception(
          "Cosmetics are not loaded yet, please try again in a while.");
    }

    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();

    final menuID = randomString(30);

    final MultiselectBuilder lockerOptions = MultiselectBuilder(
      menuID,
      [
        "outfits",
        "backblings",
        "pickaxes",
        "gliders",
        "contrails",
        "emotes",
        "toys",
        "sprays",
        "wraps",
        "music packs",
        "loading screens",
      ].map((o) => MultiselectOptionBuilder(o.upperCaseFirst(), o)),
    );

    IMessage msg = await ctx.respond(
      ComponentMessageBuilder()
        ..content = "Choose the type of locker you want to view."
        ..addComponentRow(ComponentRowBuilder()..addComponent(lockerOptions)),
    );

    try {
      var selected = await client
          .commands.interactions.events.onMultiselectEvent
          .where((event) =>
              (event.interaction.customId == menuID) &&
              event.interaction.userAuthor?.id == ctx.user.id)
          .first;

      await selected.acknowledge();

      await dbUser.fnClient.athena.init();

      List<AthenaCosmetic> cosmetics = [];

      switch (selected.interaction.values.first) {
        case "outfits":
          cosmetics = dbUser.fnClient.athena.skins;
          break;

        case "backblings":
          cosmetics = dbUser.fnClient.athena.backpacks;
          break;

        case "pickaxes":
          cosmetics = dbUser.fnClient.athena.pickaxes;
          break;

        case "gliders":
          cosmetics = dbUser.fnClient.athena.gliders;
          break;

        case "contrails":
          cosmetics = dbUser.fnClient.athena.skydiveContrails;
          break;

        case "emotes":
          cosmetics = dbUser.fnClient.athena.dances
              .where((d) => d.templateId.startsWith("AthenaDance:eid_"))
              .toList();
          break;

        case "toys":
          cosmetics = dbUser.fnClient.athena.dances
              .where((d) => d.templateId.startsWith("AthenaDance:toy_"))
              .toList();
          break;

        case "sprays":
          cosmetics = dbUser.fnClient.athena.dances
              .where((d) => d.templateId.startsWith("AthenaDance:spid_"))
              .toList();
          break;

        case "wraps":
          cosmetics = dbUser.fnClient.athena.itemWraps;
          break;

        case "music packs":
          cosmetics = dbUser.fnClient.athena.musicPacks;
          break;

        case "loading screens":
          cosmetics = dbUser.fnClient.athena.loadingScreens;
          break;

        default:
          cosmetics = dbUser.fnClient.athena.cosmetics;
          break;
      }

      if (cosmetics.isEmpty) {
        return await msg.edit(
          MessageBuilder.content(
            "You don't have any ${selected.interaction.values.first} in your locker.",
          ),
        );
      }

      List<EmbedBuilder> pages = [];
      int perPageCosmetics = 12;

      for (var i = 0; i < cosmetics.length; i += perPageCosmetics) {
        var pagesCosmeticSize = i + perPageCosmetics < cosmetics.length
            ? perPageCosmetics + i
            : cosmetics.length;

        var pageCosmetics = cosmetics.sublist(i, pagesCosmeticSize);

        var page = EmbedBuilder()
          ..author = (EmbedAuthorBuilder()
            ..name = ctx.user.username
            ..iconUrl = ctx.user.avatarURL(format: "png"))
          ..color = DiscordColor.fromHexString(dbUser.color)
          ..title = "${dbUser.activeAccount.displayName}'s Locker"
          ..thumbnailUrl = dbUser.activeAccount.avatar
          ..description =
              "Showing ${i + 1} - $perPageCosmetics of ${cosmetics.length} ${selected.interaction.values.first}."
          ..timestamp = DateTime.now()
          ..footer = (EmbedFooterBuilder()
            ..text =
                "Page ${i ~/ perPageCosmetics + 1} of ${(cosmetics.length / perPageCosmetics).ceil()}");

        for (final cosmetic in pageCosmetics) {
          String rarityEmoji = "";
          switch (cosmetic.rarity) {
            case "common":
              rarityEmoji = common.emoji;
              break;

            case "uncommon":
              rarityEmoji = uncommon.emoji;
              break;

            case "rare":
              rarityEmoji = rare.emoji;
              break;

            case "epic":
              rarityEmoji = epic.emoji;
              break;

            case "legendary":
              rarityEmoji = legendary.emoji;
              break;

            default:
              rarityEmoji = common.emoji;
              break;
          }
          page.addField(
            name: "$rarityEmoji ${cosmetic.name}",
            content:
                "${cosmetic.isFavourite ? "${star.emoji}\n" : ""}${cosmetic.isGifted ? "🎁 ${cosmetic.giftedFrom}\n" : ""}** **",
            inline: true,
          );
        }

        pages.add(page);
      }

      await msg.edit(
        EmbedComponentPagination(
          ctx.commands.interactions,
          pages,
          timeout: Duration(minutes: 3),
        ).initMessageBuilder(),
      );
    } catch (e) {
      await msg.delete();
    }
  },
  hideOriginalResponse: false,
  checks: [],
);