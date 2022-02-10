import "dart:io";
import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "package:time_ago_provider/time_ago_provider.dart" show formatFull;
import "package:pubspec_yaml/pubspec_yaml.dart";
import "../../extensions/context_extensions.dart";
import "../../fishstick_dart.dart";
import "../../utils/utils.dart";

final ChatCommand infoCommand = ChatCommand(
  "info",
  "Get basic bot info.",
  Id(
    "info_command",
    (IContext ctx) async {
      final pubspecYaml =
          (await File("pubspec.yaml").readAsString()).toPubspecYaml();

      var user = await ctx.dbUser;

      await ctx.respond(
        ComponentMessageBuilder()
          ..addEmbed((embed) {
            embed
              ..title = "Fishstick Bot Information"
              ..color = DiscordColor.fromHexString(user.color)
              ..author = (EmbedAuthorBuilder()
                ..name = client.bot.self.tag
                ..iconUrl = client.bot.self.avatarURL(format: "png"))
              ..footer = (EmbedFooterBuilder()
                ..text =
                    "Fishstick dart ${pubspecYaml.version.toString().split("(")[1].replaceAll(")", "")} | Dart SDK $dartVersion")
              ..timestamp = DateTime.now()
              ..addField(
                name: "Cached guilds (in current process)",
                content: client.bot.guilds.length,
                inline: true,
              )
              ..addField(
                name: "Cached users (in current process)",
                content: client.bot.users.length,
                inline: true,
              )
              ..addField(
                name: "Cached channels (in current process)",
                content: client.bot.channels.length,
                inline: true,
              )
              ..addField(
                name: "Cached voice states (in current process)",
                content: client.bot.guilds.values
                    .map((g) => g.voiceStates.length)
                    .reduce((f, s) => f + s),
                inline: true,
              )
              ..addField(
                name: "Cached messages (in current process)",
                content: client.bot.channels.values
                    .whereType<ITextChannel>()
                    .map((e) => e.messageCache.length)
                    .fold(0, (first, second) => (first as int) + second),
                inline: true,
              )
              ..addField(
                name: "Shard count (in current process)",
                content: client.bot.shards,
                inline: true,
              )
              ..addField(
                name: "Memory usage (current/RSS) (in current process)",
                content: getMemoryUsageString(),
              )
              ..addField(
                name: "Uptime (of current process)",
                content: formatFull(client.bot.startTime),
              );
          })
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
  aliases: ["botinfo"],
);
