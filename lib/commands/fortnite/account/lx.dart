import "package:nyxx/nyxx.dart" hide ClientOptions;
import "package:nyxx_commands/nyxx_commands.dart";
import "package:dio/dio.dart";
import "package:fortnite/fortnite.dart";
import "../../../../structures/epic_account.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../fishstick_dart.dart";

final ChatCommand lxCommand = ChatCommand(
  "lx",
  "Login to a new epic account using any grant type.",
  Id(
    "login_x_command",
    // ignore: non_constant_identifier_names
    (IContext ctx, String grant_type, String grant_data) async {
      final DatabaseUser user = await ctx.dbUser;

      if (user.linkedAccounts.length >= user.accountsLimit) {
        throw Exception("You have reached the limit of linked epic accounts.");
      }

      try {
        var res = await Dio().post(
          Endpoints().oauthTokenCreate,
          options: Options(
            headers: {
              "Authorization": "basic ${AuthClients().fortniteIOSGameClient}",
              "User-Agent":
                  "Fortnite/++Fortnite+Release-18.21-CL-17811397 Android/11",
              "Content-Type": "application/x-www-form-urlencoded",
            },
          ),
          data: "grant_type=$grant_type&$grant_data",
        );

        String accessToken = res.data["access_token"];
        String accountId = res.data["account_id"];
        String displayName = res.data["displayName"] ?? accountId;

        if (user.linkedAccounts
            .where((a) => a.accountId == accountId)
            .isNotEmpty) {
          throw Exception("You already linked this account.");
        }

        res = await Dio().post(
          "${Endpoints().oauthDeviceAuth}/$accountId/deviceAuth",
          options: Options(
            headers: {
              "Authorization": "bearer $accessToken",
              "User-Agent":
                  "Fortnite/++Fortnite+Release-18.21-CL-17811397 Android/11",
              "Content-Type": "application/json",
            },
          ),
        );

        final DeviceAuth deviceAuth = DeviceAuth(
          accountId: accountId,
          deviceId: res.data["deviceId"],
          secret: res.data["secret"],
          displayName: displayName,
        );

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
        );
      } on DioError catch (e) {
        throw Exception(e.response?.data["errorMessage"] ?? "Unknown Error");
      }
    },
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
);
