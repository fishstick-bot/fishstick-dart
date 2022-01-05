import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

final Command pingCommand = Command(
  "ping",
  "Check bot's connection to discord.",
  (Context ctx) async {
    EmbedBuilder embed = EmbedBuilder()
      ..description = "🏓Pong!"
      ..timestamp = DateTime.now();

    int start = DateTime.now().millisecondsSinceEpoch;

    IMessage msg = await ctx.respond(
      MessageBuilder.embed(
        embed..build(),
      ),
    );

    await msg.edit(
      MessageBuilder.embed(
        embed
          ..description =
              "🏓Pong! `${DateTime.now().millisecondsSinceEpoch - start}ms`"
          ..build(),
      ),
    );
  },
  aliases: ["pong"],
);
