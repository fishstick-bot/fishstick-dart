import "dart:convert";

import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";

import "package:fortnite/fortnite.dart";

import "../../../fishstick_dart.dart";

import "../../../database/database_user.dart";

import "../../../extensions/context_extensions.dart";

import "../../../structures/privacy.dart";

import "../../../resources/emojis.dart";

import "../../../utils/utils.dart";

final ChatCommand lockerExclusivesImageCommand = ChatCommand(
  "exclusives",
  "View your locker exclusive items in an image format.",
  (
    IContext ctx, [
    @Description("User to get V-Bucks balance for") IUser? user,
  ]) async {
    if (client.cachedCosmetics.isEmpty) {
      throw Exception(
          "Cosmetics are not loaded yet, please try again in a while.");
    }

    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();

    if (user != null) {
      dbUser = await client.database.getUser(user.id.toString());
      if (dbUser.linkedAccounts.isEmpty) {
        throw Exception("This user has no linked accounts.");
      }
      if (dbUser.privacyEnum == Privacy.private) {
        throw Exception("This user has set their privacy to private.");
      }
    }
    dbUser.fnClientSetup();

    await dbUser.fnClient.athena.init();

    List<AthenaCosmetic> cosmetics = filterAndSortCosmetics(
      dbUser: dbUser,
      type: "exclusives",
    );

    if (cosmetics.isEmpty) {
      return await ctx.respond(
        MessageBuilder.content(
          "${(user ?? ctx.user).username} don't have any exclusives in your locker.",
        ),
      );
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
      img = base64Decode(
        await client.imageUtils.drawLocker(
          cosmetics: cosmetics.sublist(i, sublistSize),
          epicname: dbUser.activeAccount.displayName,
        ),
      );

      await ctx.respond(
        MessageBuilder.embed(
          EmbedBuilder()
            ..author = (EmbedAuthorBuilder()
              ..name = (user ?? ctx.user).username
              ..iconUrl = (user ?? ctx.user).avatarURL(format: "png"))
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
  checks: [premiumCheck],
);
