import "package:nyxx/nyxx.dart";
import "package:nyxx_pagination/nyxx_pagination.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../extensions/context_extensions.dart";
import "../../fishstick_dart.dart";
import "../../utils/utils.dart";
import "../../resources/emojis.dart";

final ChatCommand helpCommand = ChatCommand(
  "help",
  "Get help on commands.",
  id(
    "help_command",
    (IContext ctx) async {
      var user = await ctx.dbUser;

      List<EmbedBuilder> pages = <EmbedBuilder>[];
      bool isSlash = ctx is InteractionChatContext;
      int perPageCommands = 9;

      for (var i = 0;
          i < ctx.commands.walkCommands().length;
          i += perPageCommands) {
        int pageCommandsSize =
            i + perPageCommands < ctx.commands.walkCommands().length
                ? perPageCommands + i
                : ctx.commands.walkCommands().length;

        List<ChatCommand> commandsOnPage = ctx.commands
            .walkCommands()
            .toList()
            .sublist(i, pageCommandsSize)
            .cast<ChatCommand>()
            .where((c) => !["dupe", "transfer"].contains(c.name))
            .toList();

        EmbedBuilder page = EmbedBuilder()
          ..author = (EmbedAuthorBuilder()
            ..name = ctx.user.username
            ..iconUrl = ctx.user.avatarURL(format: "png"))
          ..color = DiscordColor.fromHexString(user.color)
          ..timestamp = DateTime.now()
          ..description =
              "Showing ${i + 1} - $pageCommandsSize of ${ctx.commands.walkCommands().length} commands.\n\n• ⏱️ - ${client.commandsCooldown}s/command (50% less for premium users).\n• 🔒 - Owner only.\n• ${tick.emoji} - Fishstick partners only.\n• ${star.emoji} - Premium users only."
          ..footer = (EmbedFooterBuilder()
            ..text =
                "Page ${i ~/ perPageCommands + 1} of ${(ctx.commands.walkCommands().length / perPageCommands).ceil()}")
          ..title = "Fishstick Bot Help";

        for (final command in commandsOnPage) {
          Iterable<String> checks =
              command.checks.map((c) => c.name.split("-")[0]);

          page.addField(
            name:
                "${command.fullName}${checks.contains("owner") ? " 🔒" : ""}${checks.contains("partner") ? " ${tick.emoji}" : ""}${checks.contains("premium") ? " ${star.emoji}" : ""}",
            content:
                "${command.description}${(isSlash || command.aliases.isEmpty) ? "" : "\n• **Aliases:** ${command.aliases.join(", ")}"}",
            inline: true,
          );
        }

        pages.add(page);
      }

      await respond(
        ctx,
        EmbedComponentPagination(
          ctx.commands.interactions,
          pages,
          timeout: Duration(minutes: 3),
        ).initMessageBuilder(),
      );
    },
  ),
  aliases: ["h"],
);
