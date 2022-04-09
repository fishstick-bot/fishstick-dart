import "dart:io";
import "dart:convert";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:http/http.dart";

import "package:fortnite/fortnite.dart";

import "../../../fishstick_dart.dart";

import "../../../database/database_user.dart";

import "../../../extensions/context_extensions.dart";

import "../../../structures/privacy.dart";

import "../../../resources/emojis.dart";

Map<String, String> itemEnums = {};

final ChatCommand lockerFNGGCommand = ChatCommand(
  "fngg",
  "View your locker on fortnite.gg website.",
  Id(
    "locker_fngg_command",
    (
      IContext ctx, [
      @Description("User to view locker for") IUser? user,
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
      await Future.wait([
        dbUser.fnClient.athena.init(),
        getFortniteDotGGItemsJson(),
      ]);
      if (dbUser.fnClient.athena.cosmetics.isEmpty) {
        throw Exception("This user has no cosmetics in their locker.");
      }

      List<AthenaCosmetic> cosmetics = dbUser.fnClient.athena.cosmetics;

      if (cosmetics.isEmpty) {
        return await ctx.respond(
          MessageBuilder.content(
            "${(user ?? ctx.user).username} don't have any cosmetics in their locker.",
          ),
        );
      }

      IMessage msg = await ctx.respond(
        ComponentMessageBuilder()
          ..content = "Generating fortnite.gg link ${loading.emoji}"
          ..componentRows = [],
      );

      List<int> ints = [];
      for (final c in cosmetics) {
        if (itemEnums[c.templateId.split(":").last.toLowerCase()] != null) {
          ints.add(int.parse(
              itemEnums[c.templateId.split(":").last.toLowerCase()]!));
        }
      }
      ints.sort();
      var diff = ints.asMap().entries.map((entry) {
        var k = entry.key;
        var v = entry.value;

        if (k > 0) {
          return v - ints[k - 1];
        }
        return v;
      }).toList();
      var encoded = base64UrlEncode(
        ZLibEncoder(raw: true).convert(utf8.encode(
            "${dbUser.fnClient.athena.created.toUtc().toIso8601String()},${diff.join(",")}")),
      );

      final String fngg =
          "https://fortnite.gg/my-locker?items=$encoded&bot=fishstick-discord";
      var urlcode = await client.systemJobs.urlShortenerSystemJob.addUrl(fngg);
      final LinkButtonBuilder fnggUrl = LinkButtonBuilder(
          "Fortnite.GG Locker", "https://fishstickbot.com/tinyurl/$urlcode");

      await msg.edit(
        ComponentMessageBuilder()
          ..content = "View your fortnite.gg locker by clicking the link below."
          ..addComponentRow(
            ComponentRowBuilder()..addComponent(fnggUrl),
          ),
      );
    },
  ),
  checks: [],
);

Future<Map<String, String>> getFortniteDotGGItemsJson() async {
  itemEnums = (jsonDecode(
              (await get(Uri.parse("https://fortnite.gg/api/items.json"))).body)
          as Map)
      .cast<String, String>()
      .map((key, value) => MapEntry(key.toLowerCase(), value));
  return itemEnums;
}
