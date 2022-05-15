import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../../../../fishstick_dart.dart";

import "../../../../database/database_user.dart";

import "../../../../extensions/context_extensions.dart";
import "../../../../extensions/string_extensions.dart";

final ChatCommand deleteSurvivorSquadPreset = ChatCommand(
  "delete",
  "Delete a saved survivor squad preset.",
  id(
    "delete_survivor_squad_preset_command",
    (
      IContext ctx,
      @Description("Name for preset.") String name,
    ) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();

      if (dbUser.activeAccount.savedSurvivorSquads.isEmpty) {
        throw Exception("You don't have any saved survivor squad presets.");
      }

      if (dbUser.activeAccount.savedSurvivorSquads
          .where((s) => s.name.toLowerCase() == name.toLowerCase())
          .isEmpty) {
        throw Exception(
            "You don't have a saved survivor squad preset with that name.");
      }

      dbUser.activeAccount.savedSurvivorSquads.removeWhere(
          (s) => s.name.toLowerCase().contains(name.toLowerCase()));
      await dbUser.updateActiveAccount();

      final EmbedBuilder embed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title = "${dbUser.activeAccount.displayName}'s Survivor Squad Presets"
        ..description =
            "Delete saved survivor squad preset with name ${name.toBold()}"
        ..timestamp = DateTime.now()
        ..footer = (EmbedFooterBuilder()..text = client.footerText);

      await ctx.respond(MessageBuilder.embed(embed));
    },
  ),
  checks: [],
);
