import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:fortnite/fortnite.dart";
import "../../../fishstick_dart.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";

final Command mfaBRCommand = Command(
  "br",
  "Claim MFA rewards for battle royale gamemode.",
  (Context ctx) async {
    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();

    await dbUser.fnClient.athena.init();

    if (dbUser.fnClient.athena.stats["mfa_reward_claimed"] == true) {
      throw Exception(
          "You already claimed your MFA reward for Battle Royale gamemode.");
    }

    var res = await dbUser.fnClient.send(
      method: "POST",
      url: MCP(
        FortniteProfile.common_core,
        accountId: dbUser.fnClient.accountId,
      ).ClaimMfaEnabled,
      body: {
        "bClaimForStw": false,
      },
    );
    int profileRevision = res["profileRevision"] as int;
    int profileChangesBaseRevision = res["profileChangesBaseRevision"] as int;

    if (profileRevision < profileChangesBaseRevision) {
      throw Exception(
          "Failed to claim 2fa Rewards.\nPlease make sure that you already have two-factor authentication enabled on your account prior to attempting to claim the rewards.");
    }

    final EmbedBuilder embed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title = "${dbUser.activeAccount.displayName}'s MFA Rewards"
      ..thumbnailUrl = dbUser.activeAccount.avatar
      ..description =
          "Successfully claimed 2fa rewards for battle royale gamemode."
      ..timestamp = DateTime.now()
      ..footer = (EmbedFooterBuilder()..text = client.footerText);

    await ctx.respond(MessageBuilder.embed(embed));
  },
  hideOriginalResponse: false,
  checks: [],
);
