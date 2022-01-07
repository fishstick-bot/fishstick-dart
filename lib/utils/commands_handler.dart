import "dart:math";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../fishstick_dart.dart";
import "../extensions/context_extensions.dart";
import "utils.dart";

/// commands post call handler
void handleCommandsPostCall() {
  client.commands.onPostCall.listen((ctx) {
    ctx.disposeCache();
  });
}

/// commands error handler
void handleCommandsError() {
  /// listen for commands error and handle them
  client.commands.onCommandError.listen((exception) async {
    if (exception is CommandNotFoundException) {
      return;
    }

    if (exception is CommandInvocationException) {
      exception.context.disposeCache();
    }

    if (exception is CheckFailedException) {
      switch (exception.failed.name) {
        case "blacklist-check":
          await respond(
            exception.context,
            MessageBuilder.content("You are blacklisted from using the bot!"),
            hidden: true,
          );
          break;

        case "premium-check":
          break;

        case "partner-check":
          await respond(
            exception.context,
            MessageBuilder.content(
                "You need Fishstick partner to use this command.\nDM Vanxh#6969 for more info."),
            hidden: true,
          );
          break;

        case "owner-check":
          await respond(
            exception.context,
            MessageBuilder.content(
                "You need to be the owner of the bot to use this command."),
            hidden: true,
          );
          break;

        case "guild-check":
          await respond(
            exception.context,
            MessageBuilder.content("This command can not be done on DMs."),
            hidden: true,
          );
          break;

        case "cooldown-check":
          var m = await respond(
            exception.context,
            MessageBuilder.content(
                "You are on cooldown for this command. Please try again in a while."),
            hidden: true,
          );
          await Future.delayed(
            Duration(seconds: 2),
            () async => await m.delete(),
          );
          break;

        default:
          client.logger
              .shout("Unhandled check exception: ${exception.failed.name}");
          break;
      }
    } else if (exception is BadInputException) {
      await respond(
        exception.context,
        MessageBuilder.content("An invalid argument was provided."),
        hidden: true,
      );
    } else {
      List<String> errorTitles = [
        "💥 Uh oh! That was unexpected!",
        "⚠️ Not the LLAMA you're looking for!",
        "⚠️ There was an error!",
      ];
      if (exception is CommandInvocationException) {
        await respond(
          exception.context,
          MessageBuilder.embed(
            EmbedBuilder()
              ..title = errorTitles[Random().nextInt(errorTitles.length)]
              ..color = DiscordColor.red
              ..timestamp = DateTime.now()
              ..footer = (EmbedFooterBuilder()
                ..text = exception.runtimeType.toString())
              ..description =
                  "An error has occurred!\nYou can join our [support server](${client.config.supportServer}) to report the bug if you feel its a bug."
              ..addField(
                name: "Error",
                content: exception.message,
              ),
          ),
          hidden: true,
        );
      } else {
        client.logger
            .shout("Unhandled exception type: ${exception.runtimeType}");
      }
    }
  });
}

/// handle commands check
void handleCommandsCheckHandler() {
  /// user blacklist check for commands
  client.commands.check(
    Check((ctx) async => !(await ctx.dbUser).isBanned, "blacklist-check"),
  );

  /// cooldown check for commands
  client.commands.check(
    Check.any([
      Check.all([
        premiumCheck,
        CooldownCheck(CooldownType.user, Duration(seconds: 5), 4),
      ]),
      Check.all([
        Check.deny(premiumCheck),
        CooldownCheck(CooldownType.user, Duration(seconds: 5), 2),
      ]),
    ]),
  );
}
