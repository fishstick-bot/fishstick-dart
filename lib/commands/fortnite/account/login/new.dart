import "package:nyxx/nyxx.dart" hide ClientOptions;
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:fortnite/fortnite.dart";
import "../../../../structures/epic_account.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../fishstick_dart.dart";

final ChatCommand loginNewCommand = ChatCommand(
  "new",
  "Login to a new epic account.",
  Id(
    "login_new_command",
    (
      IContext ctx, [
      String? code,
    ]) async {
      final DatabaseUser user = await ctx.dbUser;

      if (code != null) {
        if (user.linkedAccounts.length >= user.accountsLimit) {
          throw Exception(
              "You have reached the limit of linked epic accounts.");
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

        try {
          await user.addAccount(account);

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
            )..content = "<@${ctx.user.id}>",
          );
        } on Exception catch (e) {
          await ctx.channel.sendMessage(MessageBuilder()
            ..content =
                "<@${ctx.user.id}>, An error occurred while trying to link your account.\n$e");
        }

        return;
      }

      final EmbedBuilder authorizationCodeEmbed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(user.color)
        ..footer = (EmbedFooterBuilder()
          ..text =
              "Visit Authorization Code 2 button if you wanna forcefully switch accounts.")
        ..timestamp = DateTime.now();

      final LinkButtonBuilder authorizationCodeButton = LinkButtonBuilder(
        "Authorization Code",
        getAuthorizationCodeURL(),
      );

      final LinkButtonBuilder switchAccountAuthorizationCodeButton =
          LinkButtonBuilder(
        "Authorization Code 2",
        getAuthorizationCodeURL() + "&prompt=login",
      );

      final ComponentRowBuilder authorizationCodeRow = ComponentRowBuilder()
        ..addComponent(authorizationCodeButton)
        ..addComponent(switchAccountAuthorizationCodeButton);

      await ctx.respond(
        ComponentMessageBuilder()
          ..embeds = [
            authorizationCodeEmbed
              ..color = DiscordColor.fromHexString(user.color)
              ..description =
                  "Click **Authorization Code** button to get an authorization code then do command `/login code` to login to your Epic account.",
          ]
          ..addComponentRow(authorizationCodeRow),
      );
    },
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
);