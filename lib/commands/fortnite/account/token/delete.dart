import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";

final ChatCommand accessTokenDeleteCommand = ChatCommand(
  "kill",
  "Invalidate an access token.",
  id(
    "access_token_delete_command",
    (IContext ctx, String token) async {
      DatabaseUser user = await ctx.dbUser;
      user.fnClientSetup();
      await user.fnClient.auth.killAccessToken(token: token);

      return await ctx.respond(
        MessageBuilder.content("Successfully invalidated access token."),
        private: true,
      );
    },
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [],
);
