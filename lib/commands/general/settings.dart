import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:random_string/random_string.dart";
import "../../database/database_user.dart";
import "../../extensions/context_extensions.dart";
import "../../fishstick_dart.dart";
import "../../structures/privacy.dart";
import "../../utils/utils.dart";
import "../../resources/emojis.dart";

final ChatCommand settingsCommand = ChatCommand(
  "settings",
  "Configure your bot usage settings.",
  id(
    "settings_command",
    (IContext ctx) async {
      DatabaseUser user = await ctx.dbUser;

      EmbedBuilder embed = EmbedBuilder()
        ..title = "${ctx.user.username}'s Settings"
        ..description = "Use the buttons below to configure your settings."
        ..color = DiscordColor.fromHexString(user.color)
        ..timestamp = DateTime.now()
        ..footer = (EmbedFooterBuilder()
          ..text =
              "Premium till ${user.premium.until.toUtc().toString().split(" ")[0]}");

      String autoDailyButtonId = randomString(30);
      String freeLlamasButtonId = randomString(30);
      String collectResearchButtonId = randomString(30);
      String dmNotisButtonId = randomString(30);
      String privacyButtonId = randomString(30);
      String cancelButtonId = randomString(30);

      ButtonBuilder autoDailyButton = ButtonBuilder(
        user.autoSubscriptions.dailyRewards
            ? "Disable Auto Daily"
            : "Enable Auto Daily",
        autoDailyButtonId,
        user.autoSubscriptions.dailyRewards
            ? ButtonStyle.secondary
            : ButtonStyle.primary,
        emoji: user.autoSubscriptions.dailyRewards == true
            ? cross.toEmoji()
            : tick.toEmoji(),
      );

      ButtonBuilder freeLlamaButton = ButtonBuilder(
        user.isPremium
            ? (user.autoSubscriptions.freeLlamas
                ? "Disable Auto Llamas"
                : "Enable Auto Llamas")
            : "Purchase Premium to enable auto llamas",
        freeLlamasButtonId,
        user.autoSubscriptions.freeLlamas
            ? ButtonStyle.secondary
            : ButtonStyle.primary,
        emoji: voucher_cardpack_bronze.toEmoji(),
        disabled: !user.isPremium,
      );

      ButtonBuilder researchButton = ButtonBuilder(
        user.isPremium
            ? (user.autoSubscriptions.collectResearchPoints
                ? "Disable Auto Research"
                : "Enable Auto Research")
            : "Purchase Premium to enable auto research",
        collectResearchButtonId,
        user.autoSubscriptions.collectResearchPoints
            ? ButtonStyle.secondary
            : ButtonStyle.primary,
        emoji: research.toEmoji(),
        disabled: !user.isPremium,
      );

      ButtonBuilder dmNotisButton = ButtonBuilder(
        user.dmNotifications
            ? "Disable DM Notifications"
            : "Enable DM Notifications",
        dmNotisButtonId,
        user.dmNotifications ? ButtonStyle.secondary : ButtonStyle.primary,
        emoji: UnicodeEmoji("🔔"),
      );

      ButtonBuilder privacyButton = ButtonBuilder(
        user.privacyEnum == Privacy.private
            ? "Disable Mentions Privacy"
            : "Enable Mentions Privacy",
        privacyButtonId,
        user.privacyEnum == Privacy.private
            ? ButtonStyle.secondary
            : ButtonStyle.primary,
        emoji: UnicodeEmoji("🔒"),
      );

      ButtonBuilder cancelButton = ButtonBuilder(
        "Cancel",
        cancelButtonId,
        ButtonStyle.danger,
        emoji: cross.toEmoji(),
      );

      var msg = await respond(
        ctx,
        ComponentMessageBuilder()
          ..embeds = [embed]
          ..addComponentRow(
            ComponentRowBuilder()
              ..addComponent(autoDailyButton)
              ..addComponent(freeLlamaButton)
              ..addComponent(researchButton),
          )
          ..addComponentRow(
            ComponentRowBuilder()
              ..addComponent(dmNotisButton)
              ..addComponent(privacyButton)
              ..addComponent(cancelButton),
          ),
      );

      try {
        var selected = await ctx.commands.interactions.events.onButtonEvent
            .where((event) => [
                  autoDailyButtonId,
                  freeLlamasButtonId,
                  collectResearchButtonId,
                  dmNotisButtonId,
                  privacyButtonId,
                  cancelButtonId,
                ].contains(event.interaction.customId))
            .timeout(Duration(seconds: 60))
            .first;

        await selected.acknowledge();

        if (selected.interaction.customId == cancelButtonId) {
          await selected.deleteOriginalResponse();
          return;
        } else if (selected.interaction.customId == autoDailyButtonId) {
          user.autoSubscriptions.dailyRewards =
              !user.autoSubscriptions.dailyRewards;
          await client.database.updateUser(
            user.id,
            {
              "autoSubscriptions": user.autoSubscriptions.toJson(),
            },
          );
          await msg.edit(
            ComponentMessageBuilder()
              ..embeds = []
              ..componentRows = []
              ..content =
                  "${tick.emoji} Successfully **${user.autoSubscriptions.dailyRewards ? "enabled" : "disabled"}** auto daily rewards.",
          );
        } else if (selected.interaction.customId == freeLlamasButtonId) {
          user.autoSubscriptions.freeLlamas =
              !user.autoSubscriptions.freeLlamas;
          await client.database.updateUser(
            user.id,
            {
              "autoSubscriptions": user.autoSubscriptions.toJson(),
            },
          );
          await msg.edit(
            ComponentMessageBuilder()
              ..embeds = []
              ..componentRows = []
              ..content =
                  "${tick.emoji} Successfully **${user.autoSubscriptions.freeLlamas ? "enabled" : "disabled"}** auto llamas.",
          );
        } else if (selected.interaction.customId == collectResearchButtonId) {
          user.autoSubscriptions.collectResearchPoints =
              !user.autoSubscriptions.collectResearchPoints;
          await client.database.updateUser(
            user.id,
            {
              "autoSubscriptions": user.autoSubscriptions.toJson(),
            },
          );
          await msg.edit(
            ComponentMessageBuilder()
              ..embeds = []
              ..componentRows = []
              ..content =
                  "${tick.emoji} Successfully **${user.autoSubscriptions.collectResearchPoints ? "enabled" : "disabled"}** auto research.",
          );
        } else if (selected.interaction.customId == dmNotisButtonId) {
          user.dmNotifications = !user.dmNotifications;
          await client.database.updateUser(
            user.id,
            {
              "dmNotifications": user.dmNotifications,
            },
          );
          await msg.edit(
            ComponentMessageBuilder()
              ..embeds = []
              ..componentRows = []
              ..content =
                  "${tick.emoji} Successfully **${user.dmNotifications ? "enabled" : "disabled"}** DM notifications.",
          );
        } else if (selected.interaction.customId == privacyButtonId) {
          user.privacyEnum == Privacy.private
              ? user.disableMentionsPrivacy()
              : user.enableMentionsPrivacy();

          await client.database.updateUser(
            user.id,
            {
              "privacy": user.privacy,
            },
          );
          await msg.edit(
            ComponentMessageBuilder()
              ..embeds = []
              ..componentRows = []
              ..content =
                  "${tick.emoji} Successfully **${user.privacyEnum == Privacy.private ? "enabled" : "disabled"}** mentions privacy.",
          );
        }
      } catch (e) {
        await msg.delete();
      }
      //     .listen((event) async {
      //   await selected.acknowledge();
    },
  ),
  aliases: ["config"],
);
