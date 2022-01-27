import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../../../../fishstick_dart.dart";

import "../../../../database/database_user.dart";

import "../../../../extensions/context_extensions.dart";

final Command equipSurvivorSquadPreset = Command(
  "equip",
  "Equip a saved survivor squad preset.",
  (
    Context ctx,
    @Description("Name for preset.") String name,
  ) async {
    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();
    await dbUser.fnClient.campaign.init(dbUser.activeAccount.accountId);

    if (dbUser.activeAccount.savedSurvivorSquads.isEmpty) {
      throw Exception("You don't have any saved survivor squad presets.");
    }

    if (dbUser.activeAccount.savedSurvivorSquads
        .where((s) => s.name.toLowerCase() == name.toLowerCase())
        .isEmpty) {
      throw Exception(
          "You don't have a saved survivor squad preset with that name.");
    }

    var preset = dbUser.activeAccount.savedSurvivorSquads
        .firstWhere((s) => s.name.toLowerCase() == name.toLowerCase());
    await dbUser.fnClient.campaign.equipSurvivorSquadPreset(preset);

    final EmbedBuilder embed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title = "${dbUser.activeAccount.displayName}'s Survivor Squad Presets"
      ..description = "Equipped preset: ${preset.name}"
      ..timestamp = DateTime.now()
      ..footer = (EmbedFooterBuilder()..text = client.footerText);

    await ctx.respond(MessageBuilder.embed(embed));
  },
  hideOriginalResponse: false,
  checks: [],
);
