import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:fortnite/fortnite.dart";
import "package:fishstick_dart/fishstick_dart.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";
import "../../../extensions/fortnite_extensions.dart";

final ChatCommand stwHeroLoadoutCommand = ChatCommand(
  "heroloadout",
  "Change your current hero loadout.",
  Id(
    "stw_hero_loadout_command",
    (IContext ctx) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();
      final campaign = dbUser.fnClient.campaign;

      await campaign.init(dbUser.activeAccount.accountId);

      var heroLoadouts = campaign.heroLoadouts.toList();
      heroLoadouts.sort((a, b) => a.loadoutIndex - b.loadoutIndex);

      if (heroLoadouts.isEmpty) {
        throw Exception("No hero loadouts found.");
      }

      String unique = DateTime.now().millisecondsSinceEpoch.toString();

      final EmbedBuilder embed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title =
            "[${campaign.powerLevel.toStringAsFixed(1)}] ${dbUser.activeAccount.displayName} | Save the World Hero Loadout"
        ..thumbnailUrl = dbUser.activeAccount.avatar
        ..timestamp = DateTime.now()
        ..footer = (EmbedFooterBuilder()..text = client.footerText);

      List<ComponentRowBuilder> rows = [];
      List<String> filter = [];

      var chunks = await heroLoadouts.chunk(5).toList();
      for (final loadouts in chunks) {
        final ComponentRowBuilder row = ComponentRowBuilder();
        for (final l in loadouts) {
          filter.add(l.id + unique);
          row.addComponent(
            ButtonBuilder(l.commander.name, l.id + unique, ButtonStyle.primary),
          );
        }
        rows.add(row);
      }

      await ctx.respond(
        ComponentMessageBuilder()
          ..componentRows = rows
          ..embeds = [embed],
      );

      ctx.commands.interactions.events.onButtonEvent
          .where((event) => filter.contains(event.interaction.customId))
          .timeout(Duration(minutes: 30))
          .listen((i) async {
        await i.acknowledge(hidden: true);

        int start = DateTime.now().millisecondsSinceEpoch;

        await dbUser.fnClient.post(
          MCP(
            FortniteProfile.campaign,
            accountId: dbUser.fnClient.accountId,
          ).SetActiveHeroLoadout,
          body: {
            "selectedLoadout": i.interaction.customId.replaceAll(unique, ""),
          },
        );

        await i.sendFollowup(
          MessageBuilder.content(
              "Switched loadout to ${i.interaction.customId} [${((DateTime.now().millisecondsSinceEpoch - start) / 1000).toStringAsFixed(2)}s]"),
          hidden: true,
        );
      });
    },
  ),
  checks: [],
);
