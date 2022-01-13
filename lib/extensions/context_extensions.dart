import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:random_string/random_string.dart";
import "../fishstick_dart.dart";
import "../database/database_user.dart";
import "../database/database_guild.dart";
import "../resources/emojis.dart" show filled, empty, cross, tick;

Map<String, DatabaseUser> cachedDbUsers = {};
Map<String, DatabaseGuild> cachedDbGuilds = {};

extension DB on Context {
  /// fetch the db user from the cache or database
  Future<DatabaseUser> get dbUser async {
    cachedDbUsers[user.id.toString()] ??=
        await client.database.getUser(user.id.toString());
    return cachedDbUsers[user.id.toString()] ??
        await client.database.getUser(user.id.toString());
  }

  /// fetch the db guild from the cache or database
  Future<DatabaseGuild?> get dbGuild async {
    if (guild?.id != null) {
      cachedDbGuilds[user.id.toString()] ??=
          await client.database.getGuild(guild?.id.toString() ?? "");
      return cachedDbGuilds[guild?.id.toString()] ??
          await client.database.getGuild(guild?.id.toString() ?? "");
    }

    return null;
  }

  /// dispose the cached db data
  void disposeCache() {
    if (cachedDbUsers.containsKey(user.id.toString())) {
      cachedDbUsers.remove(user.id.toString());
    }
    if (cachedDbGuilds.containsKey(guild?.id.toString() ?? "")) {
      cachedDbGuilds.remove(guild?.id.toString());
    }
  }
}

extension Util on Context {
  /// take confirmation from the user
  Future<IMessage?> takeConfirmation(String message) async {
    final String confirmButtonID = "${randomString(30)}-confirm";
    final String cancelButtonID = "${randomString(30)}-cancel";

    final ButtonBuilder confirmButton = ButtonBuilder(
      "Confirm",
      confirmButtonID,
      ComponentStyle.success,
      emoji: tick.toEmoji(),
    );

    final ButtonBuilder cancelButton = ButtonBuilder(
      "Cancel",
      cancelButtonID,
      ComponentStyle.danger,
      emoji: cross.toEmoji(),
    );

    final IMessage msg = await respond(
      ComponentMessageBuilder()
        ..addEmbed(
          (embed) async {
            embed
              ..author = (EmbedAuthorBuilder()
                ..name = user.username
                ..iconUrl = user.avatarURL(format: "png"))
              ..color = DiscordColor.fromHexString((await dbUser).color)
              ..footer = (EmbedFooterBuilder()
                ..text = "This message will timeout in 1 minute.")
              ..timestamp = DateTime.now()
              ..description = message;
          },
        )
        ..addComponentRow(
          ComponentRowBuilder()
            ..addComponent(confirmButton)
            ..addComponent(cancelButton),
        ),
    );

    try {
      var selected = await client.commands.interactions.events.onButtonEvent
          .where((event) => ([confirmButtonID, cancelButtonID]
                  .contains(event.interaction.customId) &&
              event.interaction.userAuthor?.id == user.id))
          .timeout(Duration(minutes: 1))
          .first;
      await selected.acknowledge();

      if (selected.interaction.customId.contains("confirm")) {
        return msg;
      }

      // ignore: empty_catches
    } catch (e) {}

    await msg.delete();

    return null;
  }

  /// create a progress bar
  String createProgressBar(double frac) {
    num n = (frac * 10).round();
    return "${filled.toEmoji()}" * n.toInt() +
        "${empty.toEmoji()}" * (10 - n).toInt();
  }
}
