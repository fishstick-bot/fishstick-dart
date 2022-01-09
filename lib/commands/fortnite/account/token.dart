import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:fortnite/fortnite.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";
import "../../../utils/utils.dart";

final Command accessTokenCommand = Command(
  "token",
  "Create an access token used to authenticate with fortnite api.",
  (Context ctx) async {
    DatabaseUser user = await ctx.dbUser;
    user.fnClientSetup();

    return await ctx.respond(
      MessageBuilder.content("${await (user.fnClient.auth.createOAuthToken(
        grantType: "device_auth",
        grantData:
            "account_id=${user.fnClient.accountId}&device_id=${user.fnClient.deviceId}&secret=${user.fnClient.secret}",
        authClient: AuthClients().fortniteIOSGameClient,
        tokenType: "bearer",
      ))}"),
      private: true,
    );
  },
  hideOriginalResponse: true,
  checks: [ownerCheck],
);
