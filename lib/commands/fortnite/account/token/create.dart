import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:fortnite/fortnite.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";

final ChatCommand accessTokenCreateCommand = ChatCommand(
  "create",
  "Create an access token used to authenticate with fortnite api.",
  id(
    "access_token_create_command",
    (IContext ctx) async {
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
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [],
);
