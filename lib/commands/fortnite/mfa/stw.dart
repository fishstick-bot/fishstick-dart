import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:fortnite/fortnite.dart";
import "../../../fishstick_dart.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";

final ChatCommand mfaSTWCommand = ChatCommand(
  "stw",
  "Claim MFA rewards for save the world royale gamemode.",
  Id(
    "mfa_stwcommand",
    (IContext ctx) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();

      await Future.wait([
        dbUser.fnClient.campaign.init(dbUser.fnClient.accountId),
        dbUser.fnClient.commonCore.init(),
      ]);

      var campaignAccess = dbUser.fnClient.commonCore.items
          .where((item) => item.templateId.contains("campaignaccess"));

      if (campaignAccess.isEmpty) {
        throw Exception("You don't have access to Save the World gamemode.");
      }

      if (dbUser.fnClient.campaign.stats["mfa_reward_claimed"] == true) {
        throw Exception(
            "You already claimed your MFA reward for Save the World gamemode.");
      }

      var res = await dbUser.fnClient.send(
        method: "POST",
        url: MCP(
          FortniteProfile.common_core,
          accountId: dbUser.fnClient.accountId,
        ).ClaimMfaEnabled,
        body: {
          "bClaimForStw": true,
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
            "Successfully claimed 2fa rewards for save the world royale gamemode."
        ..timestamp = DateTime.now()
        ..footer = (EmbedFooterBuilder()..text = client.footerText);

      await ctx.respond(MessageBuilder.embed(embed));
    },
  ),
  checks: [],
);
