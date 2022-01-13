import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";

final Command gameLaunchCommand = Command(
  "launch",
  "Creates launch arguments to launch your game on windows device.",
  (
    Context ctx, [
    @Description("Path to Win64 directory.") String path =
        "C:\\Program Files\\Epic Games\\Fortnite\\FortniteGame\\Binaries\\Win64",
  ]) async {
    DatabaseUser user = await ctx.dbUser;
    user.fnClientSetup();

    return await ctx.respond(
      MessageBuilder.content(
          "Copy and paste the text below into a Command Prompt window (cmd.exe) and hit enter. Valid for 5 minutes, until it's used.")
        ..appendCodeSimple(
            "start /d \"$path\" FortniteLauncher.exe -AUTH_LOGIN=unused -AUTH_PASSWORD=${await (user.fnClient.auth.createExchangeCode())} -AUTH_TYPE=exchangecode -epicapp=Fortnite -epicenv=Prod -EpicPortal -epicuserid=${user.fnClient.accountId}"),
      private: true,
    );
  },
  hideOriginalResponse: true,
  checks: [],
);
