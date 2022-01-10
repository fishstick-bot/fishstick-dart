import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";

final Command exchangeCodeCreateCommand = Command(
  "create",
  "Create an exchange code used to authenticate with fortnite api.",
  (Context ctx) async {
    DatabaseUser user = await ctx.dbUser;
    user.fnClientSetup();

    return await ctx.respond(
      MessageBuilder.content(await (user.fnClient.auth.createExchangeCode())),
      private: true,
    );
  },
  hideOriginalResponse: true,
  checks: [],
);
