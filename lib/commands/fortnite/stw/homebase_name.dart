import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:fortnite/fortnite.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";
import "../../../extensions/string_extensions.dart";
import "../../../fishstick_dart.dart";

final ChatCommand homebaseNameCommand = ChatCommand(
  "homebase-name",
  "View/change your save the world gamemode homebase name.",
  (
    IContext ctx, [
    @Description("The new homebase name.") String? update,
  ]) async {
    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();
    final campaign = dbUser.fnClient.campaign;

    var responses = await Future.wait([
      campaign.init(dbUser.activeAccount.accountId),
      dbUser.fnClient.send(
        method: "POST",
        url: MCP(FortniteProfile.common_public,
                accountId: dbUser.activeAccount.accountId)
            .QueryProfile,
        body: {},
      )
    ]);

    if (!campaign.tutorialCompleted) {
      throw Exception(
          "You haven't completed the tutorial yet. Please complete the tutorial before using this command.");
    }

    String current = (responses.last["profileChanges"] as List?)
            ?.first?["profile"]?["stats"]?["attributes"]?["homebase_name"] ??
        "";

    if (update != null) {
      await dbUser.fnClient.send(
        method: "POST",
        url: MCP(FortniteProfile.common_public,
                accountId: dbUser.activeAccount.accountId)
            .SetHomebaseName,
        body: {
          "homebaseName": update,
        },
      );
    }

    final EmbedBuilder embed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title =
          "[${campaign.powerLevel.toStringAsFixed(1)}] ${dbUser.activeAccount.displayName} | Homebase Name"
      ..thumbnailUrl = dbUser.activeAccount.avatar
      ..description = update != null
          ? "Successfully updated homebase name from ${current.toBold()} to ${update.toBold()}."
          : "Current homebase name - ${current.toBold()}"
      ..timestamp = DateTime.now()
      ..footer = (EmbedFooterBuilder()..text = client.footerText);

    await ctx.respond(MessageBuilder.embed(embed));
  },
  checks: [],
);
