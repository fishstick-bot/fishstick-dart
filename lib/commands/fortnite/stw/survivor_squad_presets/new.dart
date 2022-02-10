import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../../../../fishstick_dart.dart";

import "../../../../database/database_user.dart";

import "../../../../structures/stw_survivor_squad_preset.dart";

import "../../../../extensions/context_extensions.dart";
import "../../../../extensions/string_extensions.dart";

final ChatCommand newSurvivorSquadPreset = ChatCommand(
  "new",
  "Create a new survivor squad preset.",
  (
    IContext ctx,
    @Description("Name for preset.") String name,
  ) async {
    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();
    await dbUser.fnClient.campaign.init(dbUser.activeAccount.accountId);

    if (dbUser.activeAccount.savedSurvivorSquads.length >= 10) {
      throw Exception(
          "You have too many saved survivor squads, please delete some.");
    }

    if (dbUser.activeAccount.savedSurvivorSquads
        .where((s) => s.name.toLowerCase() == name.toLowerCase())
        .isNotEmpty) {
      throw Exception("A survivor squad with that name already exists.");
    }

    dbUser.activeAccount.savedSurvivorSquads.add(
      STWSurvivorSquadPreset.fromJson(
          dbUser.fnClient.campaign.survivorSquadPreset.toJson()
            ..addEntries([MapEntry("name", name.toLowerCase())])),
    );
    await dbUser.updateActiveAccount();

    final EmbedBuilder embed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title = "${dbUser.activeAccount.displayName}'s Survivor Squad Presets"
      ..description = "Saved current survivor squad preset as ${name.toBold()}"
      ..timestamp = DateTime.now()
      ..footer = (EmbedFooterBuilder()..text = client.footerText);

    await ctx.respond(MessageBuilder.embed(embed));
  },
  checks: [],
);
