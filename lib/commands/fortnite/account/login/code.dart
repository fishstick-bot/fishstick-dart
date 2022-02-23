import "package:nyxx/nyxx.dart" hide ClientOptions;
import "package:nyxx_commands/nyxx_commands.dart";
import "package:fortnite/fortnite.dart";
import "../../../../structures/epic_account.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../fishstick_dart.dart";

final ChatCommand loginCodeCommand = ChatCommand(
  "code",
  "Login to a new epic account.",
  Id(
    "login_code_command",
    (IContext ctx,
        @Description("The authorization code for your account. (Get it from /login new)")
            String code) async {
      final DatabaseUser user = await ctx.dbUser;

      if (user.linkedAccounts.length >= user.accountsLimit) {
        throw Exception("You have reached the limit of linked epic accounts.");
      }

      final DeviceAuth deviceAuth =
          await authenticateWithAuthorizationCode(code);

      if (user.linkedAccounts
          .where((a) => a.accountId == deviceAuth.accountId)
          .isNotEmpty) {
        throw Exception("You already linked this account.");
      }

      final Client fn = Client(
        options: ClientOptions(
          deviceAuth: deviceAuth,
          logLevel: Level.INFO,
        ),
      )..onSessionUpdate.listen((Client update) {
          user.sessions[update.accountId] = update.session;
        });

      final EpicAccount account = EpicAccount.fromJson({
        "accountId": deviceAuth.accountId,
        "deviceId": client.encryptString(deviceAuth.deviceId),
        "secret": client.encryptString(deviceAuth.secret),
        "displayName": deviceAuth.displayName,
        "avatar": (await fn.getAvatars([fn.accountId])).first.icon,
        "cachedResearchValues": {
          "fortitude": 0,
          "resistance": 0,
          "offense": 0,
          "tech": 0,
        },
        "dailiesLastRefresh": 0,
        "lastDailyRewardClaim": 0,
        "lastFreeLlamasClaim": 0,
        "powerLevel": 0,
        "savedHeroLoadouts": [],
        "savedSurvivorSquads": [],
      });

      await user.addAccount(account);
      await user.setActiveAccount(account.accountId);

      await ctx.respond(
        MessageBuilder.embed(
          EmbedBuilder()
            ..author = (EmbedAuthorBuilder()
              ..name = ctx.user.username
              ..iconUrl = ctx.user.avatarURL(format: "png"))
            ..color = DiscordColor.fromHexString(user.color)
            ..title = "👋 Welcome, ${account.displayName}"
            ..thumbnailUrl = account.avatar
            ..description =
                "Your epic account has been successfully linked to your discord account."
            ..addField(
              name: "Account ID",
              content: account.accountId,
              inline: true,
            )
            ..timestamp = DateTime.now()
            ..footer = (EmbedFooterBuilder()..text = client.footerText),
        ),
        private: true,
      );
    },
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
);
