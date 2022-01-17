import "dart:io";

import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";

import "package:fortnite/fortnite.dart";

import "package:image_extensions/image_extensions.dart";

import "package:random_string/random_string.dart";

import "../../../fishstick_dart.dart";

import "../../../database/database_user.dart";

import "../../../extensions/context_extensions.dart";
import "../../../extensions/string_extensions.dart";
import "../../../extensions/fortnite_extensions.dart";

import "../../../resources/emojis.dart";

import "../../../utils/utils.dart";

final Command lockerImageCommand = Command(
  "image",
  "View your locker in a image format.",
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

      for (final c in cosmetics) {
        await Directory("cosmetics/${c.type.toLowerCase()}")
            .create(recursive: true);

        if (!(await File(c.imagePath).exists())) {
          await (await client.imageUtils.drawFortniteCosmetic(
            icon: c.image,
            rarity: c.rarity,
            isExclusive: c.isExclusive,
          ))
              .saveAsPNG(c.imagePath);
        }
      }

      cosmetics.sort((a, b) => a.name.compareTo(b.name));
      cosmetics.sort((a, b) =>
          raritiesPriority.keys.toList().indexOf(b.rarity) -
          raritiesPriority.keys.toList().indexOf(a.rarity));

      await msg.edit(
        ComponentMessageBuilder()
          ..content =
              "Rendering locker image for ${selected.interaction.values.first} ${loading.emoji}"
          ..componentRows = [],
      );

      List<int> img;
      for (var i = 0; i < cosmetics.length; i += 500) {
        int sublistSize =
            i + 500 < cosmetics.length ? 500 + i : cosmetics.length;

        int startTime = DateTime.now().millisecondsSinceEpoch;
        img = encodeJpg(
          await client.imageUtils
              .drawLocker(cosmetics: cosmetics.sublist(i, sublistSize)),
          quality: 75,
        );

        await ctx.respond(
          MessageBuilder.embed(
            EmbedBuilder()
              ..author = (EmbedAuthorBuilder()
                ..name = ctx.user.username
                ..iconUrl = ctx.user.avatarURL(format: "png"))
              ..description =
                  "Rendered locker image in ${((DateTime.now().millisecondsSinceEpoch - startTime) / 1000).toStringAsFixed(2)}s"
              ..color = DiscordColor.fromHexString(dbUser.color)
              ..title = "${dbUser.activeAccount.displayName}'s Locker"
              ..timestamp = DateTime.now()
              ..footer = (EmbedFooterBuilder()..text = client.footerText)
              ..imageUrl = "attachment://locker-$i.png",
          )
            ..addAttachment(
              AttachmentBuilder.bytes(
                img,
                "locker-$i.png",
              ),
            )
            ..content = ctx.user.mention,
        );
      }

      await msg.delete();
    } catch (e) {
      client.logger.shout(e);
      await msg.delete();
    }
  },
  hideOriginalResponse: false,
  checks: [],
);
