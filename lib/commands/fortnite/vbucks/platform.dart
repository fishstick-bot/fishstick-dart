import "package:fortnite/fortnite.dart";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
// import "package:fortnite/fortnite.dart";
import "../../../fishstick_dart.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../resources/emojis.dart";

final Command vbucksPlatformCommand = Command(
  "platform",
  "Change your V-Bucks platform for purchases in the item shop.",
  (
    Context ctx,
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
    await dbUser.fnClient.send(
      method: "POST",
      url:
          MCP(FortniteProfile.common_core, accountId: dbUser.fnClient.accountId)
              .SetMtxPlatform,
      body: {
        "newPlatform": platform,
      },
    );

    final EmbedBuilder vBucksEmbed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title = "${dbUser.activeAccount.displayName}'s V-Bucks Platform"
      ..description =
          "${tick.emoji} Successfully updated your V-Bucks platform from **${dbUser.fnClient.commonCore.stats["current_mtx_platform"]}** to **$platform**."
      ..timestamp = DateTime.now()
      ..footer = (EmbedFooterBuilder()..text = client.footerText);

    await ctx.respond(MessageBuilder.embed(vBucksEmbed));
  },
  hideOriginalResponse: false,
  checks: [],
);
