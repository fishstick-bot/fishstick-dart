import "dart:math";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../client/client.dart";
import "../extensions/context_extensions.dart";
import "utils.dart";

/// commands post call handler
void handleCommandsPostCall(CommandsPlugin commands) {
  commands.onPostCall.listen((ctx) {
    ctx.disposeCache();
  });
}

/// commands error handler
void handleCommandsError(Client client, CommandsPlugin commands) {
  /// listen for commands error and handle them
  commands.onCommandError.listen((exception) async {
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
          await exception.context.respond(
            MessageBuilder.content(
              "You need to be a premium user to use this command! Contact Vanxh#6969 for more information.",
            ),
            private: true,
          );
          break;

        case "partner-check":
          await exception.context.respond(
            MessageBuilder.content(
                "You need Fishstick partner to use this command.\nContact Vanxh#6969 for more information."),
            private: true,
          );
          break;

        case "owner-check":
          await exception.context.respond(
            MessageBuilder.content(
                "You need to be the owner of the bot to use this command."),
            private: true,
          );
          break;

        case "guild-check":
          await exception.context.respond(
            MessageBuilder.content("This command can not be done on DMs."),
            private: true,
          );
          break;

        case "Any of [All of [premium-check, Cooldown Check on CooldownType[User]], All of [Denied premium-check, Cooldown Check on CooldownType[User]]]":
          var m = await respond(
            exception.context,
            MessageBuilder.content(
                "You are on cooldown for this command. Please try again in a while."),
            hidden: true,
          );
          await Future.delayed(
            Duration(seconds: 3),
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
void handleCommandsCheckHandler(CommandsPlugin commands, int commandsCooldown) {
  /// user blacklist check for commands
  commands.check(
    Check((ctx) async => !(await ctx.dbUser).isBanned, "blacklist-check"),
  );

  /// cooldown check for commands
  commands.check(
    Check.any([
      Check.all([
        Check.deny(premiumCheck),
        CooldownCheck(
          CooldownType.user,
          Duration(seconds: commandsCooldown),
        ),
      ]),
      Check.all([
        premiumCheck,
        CooldownCheck(
          CooldownType.user,
          Duration(seconds: (commandsCooldown / 2).round()),
        ),
      ]),
    ]),
  );

  /// make text commands only be useable on DMs.
  commands.check(
    Check.any([
      Check((context) => context
          is InteractionContext), // Allows interaction commands to be ran anywhere
      GuildCheck.none(),
    ]),
  );
}
