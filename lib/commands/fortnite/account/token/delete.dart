import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";

final Command accessTokenDeleteCommand = Command(
  "kill",
  "Invalidate an access token.",
  (Context ctx, String token) async {
    DatabaseUser user = await ctx.dbUser;
    user.fnClientSetup();
    await user.fnClient.auth.killAccessToken(token: token);

    return await ctx.respond(
      MessageBuilder.content("Successfully invalidated access token."),
      private: true,
    );
  },
  hideOriginalResponse: true,
  checks: [],
);
