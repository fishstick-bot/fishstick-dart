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

final ChatCommand lockerFullImageCommand = ChatCommand(
  "full",
  "View your locker in an image format.",
  id(
    "locker_full_image_command",
    (
      IContext ctx, [
      @Description("User to view locker for") IUser? user,
      @Description("PNG quality") bool png = false,
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
      if (dbUser.fnClient.athena.cosmetics.isEmpty) {
        throw Exception("This user has no cosmetics in their locker.");
      }

      List<AthenaCosmetic> cosmetics = filterAndSortCosmetics(
        dbUser: dbUser,
        type: "all",
      );

      if (cosmetics.isEmpty) {
        return await ctx.respond(
          MessageBuilder.content(
            "${(user ?? ctx.user).username} don't have any cosmetics in their locker.",
          ),
        );
      }

      final IMessage msg = await ctx.respond(
        ComponentMessageBuilder()
          ..content = "Rendering full locker image ${loading.emoji}"
          ..componentRows = [],
      );

      List<List<AthenaCosmetic>> chunks = await cosmetics.chunk(750).toList();

      List<int> img;
      for (var i = 0; i < chunks.length; i++) {
        int startTime = DateTime.now().millisecondsSinceEpoch;
        img = await drawLocker(
          cosmetics: chunks[i],
          epicname: dbUser.fnClient.displayName,
          username:
              "${(user ?? ctx.user).tag}${chunks.length > 1 ? " [${i + 1}/${chunks.length})]" : ""}",
          png: png,
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
              ..title = "${dbUser.activeAccount.displayName}'s Full Locker"
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
  ),
  checks: [premiumCheck],
);
