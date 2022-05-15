import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";

import "package:fortnite/fortnite.dart";

import "package:random_string/random_string.dart";

import "../../../fishstick_dart.dart";

import "../../../database/database_user.dart";

import "../../../extensions/context_extensions.dart";

import "../../../structures/privacy.dart";

import "../../../resources/emojis.dart";

import "../../../utils/utils.dart";

final ChatCommand lockerImageCommand = ChatCommand(
  "image",
  "View your locker in an image format.",
  id(
    "locker_image_command",
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

      final menuID = randomString(30);

      final MultiselectBuilder lockerOptions =
          lockerOptionsBuilder(menuID, dbUser.fnClient.athena);

      IMessage msg = await ctx.respond(
        ComponentMessageBuilder()
          ..content = "Choose the type of locker you want to view."
          ..addComponentRow(ComponentRowBuilder()..addComponent(lockerOptions)),
      );

      var selected = await ctx.commands.interactions.events.onMultiselectEvent
          .where((event) =>
              (event.interaction.customId == menuID) &&
              event.interaction.userAuthor?.id == ctx.user.id)
          .first;

      await selected.acknowledge();

      List<AthenaCosmetic> cosmetics = filterAndSortCosmetics(
        dbUser: dbUser,
        type: selected.interaction.values.first,
      );

      if (cosmetics.isEmpty) {
        return await msg.edit(
          MessageBuilder.content(
            "${(user ?? ctx.user).username} don't have any ${selected.interaction.values.first} in their locker.",
          ),
        );
      }

      await msg.edit(
        ComponentMessageBuilder()
          ..content =
              "Rendering locker image for ${selected.interaction.values.first} ${loading.emoji}"
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
    },
  ),
  checks: [],
);
