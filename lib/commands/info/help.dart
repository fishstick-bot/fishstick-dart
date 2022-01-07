import "package:nyxx/nyxx.dart";
import "package:nyxx_pagination/nyxx_pagination.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../extensions/context_extensions.dart";
import "../../fishstick_dart.dart";
import "../../utils/utils.dart";

final Command helpCommand = Command(
  "help",
  "Get help on commands.",
  (Context ctx) async {
    var user = await ctx.dbUser;

    List<EmbedBuilder> pages = <EmbedBuilder>[];
    bool isSlash = ctx is InteractionContext;
    int perPageCommands = 9;

    for (var i = 0;
        i < client.commands.walkCommands().length;
        i += perPageCommands) {
      int pageCommandsSize =
          i + perPageCommands < client.commands.walkCommands().length
              ? perPageCommands + i
              : client.commands.walkCommands().length;

      List<Command> commandsOnPage = client.commands
          .walkCommands()
          .toList()
          .sublist(i, pageCommandsSize)
          .toList();

      EmbedBuilder page = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(user.color)
        ..timestamp = DateTime.now()
        ..description =
            "Showing ${i + 1} - $pageCommandsSize of ${client.commands.walkCommands().length} commands.\n• Cooldown: ${client.commandsCooldown}s/command (50% less for premium users)."
        ..footer = (EmbedFooterBuilder()
          ..text =
              "Page ${i ~/ perPageCommands + 1} of ${(client.commands.walkCommands().length / perPageCommands).ceil()}")
        ..title = "Fishstick Bot Help";

      for (var command in commandsOnPage) {
        page.addField(
          name: command.fullName,
          content:
              "${command.description}${(isSlash || command.aliases.isEmpty) ? "" : "\n• **Aliases:** ${command.aliases.join(", ")}"}",
          inline: true,
        );
      }

      pages.add(page);
    }

    await respond(
      ctx,
      EmbedComponentPagination(ctx.commands.interactions, pages)
          .initMessageBuilder(),
    );
  },
  aliases: ["h"],
);
