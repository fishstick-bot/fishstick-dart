import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";
import "../../../utils/utils.dart";

final ChatCommand authcodeCommand = ChatCommand(
  "authcode",
  "Get your authorization code for your account.",
  Id(
    "authcode_command",
    (
      IContext ctx, [
      @Description("Client ID to get authorization code for.")
          String clientId = "3446cd72694c4a4485d81b77adbb2141",
    ]) async {
      DatabaseUser user = await ctx.dbUser;
      user.fnClientSetup();

      await user.fnClient.commonCore
          .init(); // just to make sure token is valid.
      final res = await webApiRequest(
        "https://www.epicgames.com/id/api/redirect?clientId=$clientId&responseType=code",
        user.fnClient.session,
      );

      return await ctx.respond(
        MessageBuilder.content(
            "${res["authorizationCode"] ?? "Unknown error."}"),
        private: true,
      );
    },
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [],
);
