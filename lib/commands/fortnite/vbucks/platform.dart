import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
// import "package:fortnite/fortnite.dart";
import "../../../fishstick_dart.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../resources/emojis.dart";

final ChatCommand vbucksPlatformCommand = ChatCommand(
  "platform",
  "Change your V-Bucks platform for purchases in the item shop.",
  Id(
    "vbucks_platform_command",
    (
      IContext ctx,
      @Description("The platform you want to use.")
      @Choices({
        "Playstation": "PSN",
        "Xbox": "Live",
        "Epic": "Epic",
        "Epic PC": "EpicPC",
        "Epic PC Korea": "EpicPCKorea",
        "Shared": "Shared",
        "IOS": "IOSAppStore",
        "Android": "EpicAndroid",
        "Nintendo": "Nintendo",
        "Samsung": "Samsung",
        "WeGame": "wegame",
      })
          String platform,
    ) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();

      await dbUser.fnClient.commonCore.init();
      await dbUser.fnClient.commonCore.setMtxPlatform(platform);

      final EmbedBuilder vBucksEmbed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(dbUser.color)
        ..title = "${dbUser.activeAccount.displayName}'s V-Bucks Platform"
        ..thumbnailUrl = dbUser.activeAccount.avatar
        ..description =
            "${tick.emoji} Successfully updated your V-Bucks platform from **${dbUser.fnClient.commonCore.currentMtxPlatform}** to **$platform**."
        ..timestamp = DateTime.now()
        ..footer = (EmbedFooterBuilder()..text = client.footerText);

      await ctx.respond(MessageBuilder.embed(vBucksEmbed));
    },
  ),
  checks: [],
);
