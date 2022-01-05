import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../extensions/context_extensions.dart";
import "../../fishstick_dart.dart";

final Command pingCommand = Command(
  "ping",
  "Check bot's connection to discord.",
  (Context ctx) async {
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
  aliases: ["pong"],
);
