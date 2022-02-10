import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";

final ChatCommand accessTokenDeleteAllCommand = ChatCommand(
  "kill-all",
  "Kill all active sessions of account.",
  Id(
    "access_token_delete_all_command",
    Id(
      "access_token_delete_all_command",
      (IContext ctx, String token) async {
        DatabaseUser user = await ctx.dbUser;
        user.fnClientSetup();
        await user.fnClient.auth.killSessions("ALL");

        return await ctx.respond(
          MessageBuilder.content(
              "Successfully invalidated all active account sessions."),
          private: true,
        );
      },
    ),
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [],
);
