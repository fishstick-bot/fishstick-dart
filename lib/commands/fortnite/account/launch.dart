import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";

final ChatCommand gameLaunchCommand = ChatCommand(
  "launch",
  "Creates launch arguments to boot your game on Windows devices.",
  id(
    "launch_command",
    (
      IContext ctx, [
      @Description("Path to FortniteLauncher.exe - can be found in your Win64 directory.") String path =
          "C:\\Program Files\\Epic Games\\Fortnite\\FortniteGame\\Binaries\\Win64\\FortniteLauncher.exe",
    ]) async {
      DatabaseUser user = await ctx.dbUser;
      user.fnClientSetup();

      return await ctx.respond(
        MessageBuilder.content(
            "Copy and paste the text below into a Command Prompt window (cmd.exe) and hit enter. Valid for 5 minutes, until it's used.")
          ..appendCodeSimple(
              "\"$path\" -AUTH_LOGIN=unused -AUTH_PASSWORD=${await (user.fnClient.auth.createExchangeCode())} -AUTH_TYPE=exchangecode -epicapp=Fortnite -epicenv=Prod -EpicPortal -epicuserid=${user.fnClient.accountId}"),
        private: true,
      );
    },
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [],
);
