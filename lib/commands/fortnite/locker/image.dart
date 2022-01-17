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
import "../../../extensions/fortnite_extensions.dart";

import "../../../resources/emojis.dart";

import "../../../utils/utils.dart";

final Command lockerImageCommand = Command(
  "image",
  "View your locker in an image format.",
  (Context ctx) async {
    if (client.cachedCosmetics.isEmpty) {
      throw Exception(
          "Cosmetics are not loaded yet, please try again in a while.");
    }

    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();

    final menuID = randomString(30);

    final MultiselectBuilder lockerOptions = lockerOptionsBuilder(menuID);

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

      List<AthenaCosmetic> cosmetics = filterAndSortCosmetics(
        dbUser: dbUser,
        type: selected.interaction.values.first,
      );

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
      await msg.delete();
    }
  },
  hideOriginalResponse: false,
  checks: [],
);
