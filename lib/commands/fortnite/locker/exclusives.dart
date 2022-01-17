import "dart:io";

import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";

import "package:fortnite/fortnite.dart";

import "package:image_extensions/image_extensions.dart";

import "../../../fishstick_dart.dart";

import "../../../database/database_user.dart";

import "../../../extensions/context_extensions.dart";
import "../../../extensions/fortnite_extensions.dart";

import "../../../resources/emojis.dart";

import "../../../utils/utils.dart";

final Command lockerExclusivesImageCommand = Command(
  "exclusives",
  "View your locker exclusive items in an image format.",
  (Context ctx) async {
    if (client.cachedCosmetics.isEmpty) {
      throw Exception(
          "Cosmetics are not loaded yet, please try again in a while.");
    }

    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();

    await dbUser.fnClient.athena.init();

    List<AthenaCosmetic> cosmetics = filterAndSortCosmetics(
      dbUser: dbUser,
      type: "all",
    ).where((c) => c.isExclusive).toList();

    if (cosmetics.isEmpty) {
      return await ctx.respond(
        MessageBuilder.content(
          "You don't have any exclusives in your locker.",
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

    IMessage msg = await ctx.respond(
      ComponentMessageBuilder()
        ..content = "Rendering locker image for exclusives ${loading.emoji}"
        ..componentRows = [],
    );

    List<int> img;
    for (var i = 0; i < cosmetics.length; i += 500) {
      int sublistSize = i + 500 < cosmetics.length ? 500 + i : cosmetics.length;

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
            ..title = "${dbUser.activeAccount.displayName}'s Exclusives Locker"
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
  },
  hideOriginalResponse: false,
  checks: [
    premiumCheck,
    CooldownCheck(CooldownType.global, Duration(seconds: 5), 3),
  ],
);
