import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../../../../fishstick_dart.dart";

import "../../../../database/database_user.dart";

import "../../../../extensions/context_extensions.dart";
import "../../../../extensions/string_extensions.dart";

final ChatCommand listSurvivorSquadPresets = ChatCommand(
  "list",
  "View your saved survivor squad presets.",
  id(
    "list_survivor_squad_preset_command",
    (IContext ctx) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();

      if (dbUser.activeAccount.savedSurvivorSquads.isEmpty) {
        throw Exception("You have no saved survivor squad presets.");
      }

      final EmbedBuilder embed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title = "${dbUser.activeAccount.displayName}'s Survivor Squad Presets"
        ..description = dbUser.activeAccount.savedSurvivorSquads
            .map((squad) => "• ${squad.name.toBold()}")
            .join("\n")
        ..timestamp = DateTime.now()
        ..footer = (EmbedFooterBuilder()..text = client.footerText);

      await ctx.respond(MessageBuilder.embed(embed));
    },
  ),
  checks: [],
);
