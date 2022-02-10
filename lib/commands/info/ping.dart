import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../extensions/context_extensions.dart";
import "../../fishstick_dart.dart";

final ChatCommand pingCommand = ChatCommand(
  "ping",
  "Check bot's connection to discord.",
  Id(
    "ping_command",
    (IContext ctx) async {
      await ctx.respond(
        MessageBuilder.embed(
          EmbedBuilder()
            ..description =
                "🏓Pong! `${client.bot.shardManager.gatewayLatency.inMilliseconds}ms`"
            ..color = DiscordColor.fromHexString((await ctx.dbUser).color)
            ..footer = (EmbedFooterBuilder()..text = client.footerText)
            ..timestamp = DateTime.now(),
        ),
      );
    },
  ),
  aliases: ["pong"],
);
