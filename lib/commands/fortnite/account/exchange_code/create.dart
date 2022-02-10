import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";

final ChatCommand exchangeCodeCreateCommand = ChatCommand(
  "create",
  "Create an exchange code used to authenticate with fortnite api.",
  (IContext ctx) async {
    DatabaseUser user = await ctx.dbUser;
    user.fnClientSetup();

    return await ctx.respond(
      MessageBuilder.content(await (user.fnClient.auth.createExchangeCode())),
      private: true,
    );
  },
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [],
);
