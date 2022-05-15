import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:nyxx_commands/nyxx_commands.dart";
// import "../../extensions/context_extensions.dart";
import "../../fishstick_dart.dart";

final ChatCommand inviteCommand = ChatCommand(
  "invite",
  "Get bot's invite link.",
  id(
    "invite_command",
    (IContext ctx) async {
      await ctx.respond(
        ComponentMessageBuilder()
          ..content = "**Invite links:**"
          ..addComponentRow(
            ComponentRowBuilder()
              ..addComponent(
                LinkButtonBuilder(
                  "Invite Me",
                  "https://discord.com/oauth2/authorize?client_id=${client.bot.self.id.toString()}&permissions=535999016001&scope=bot%20applications.commands",
                  emoji: UnicodeEmoji("📫"),
                ),
              )
              ..addComponent(
                LinkButtonBuilder(
                  "Support Server",
                  client.config.supportServer,
                  emoji: UnicodeEmoji("⚒️"),
                ),
              ),
          ),
      );
    },
  ),
  aliases: ["inv"],
);
