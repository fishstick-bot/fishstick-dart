import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_guild.dart";
import "../../extensions/context_extensions.dart";
import "../../utils/utils.dart";
import "../../fishstick_dart.dart";

final Group autopostCommand = Group(
  "autopost",
  "Configure auto post settings.",
  children: [
    Command(
      "vbucks-alerts",
      "Configure settings for auto post vbucks alerts.",
      (Context ctx, IChannel channel, [IRole? role]) async {
        DatabaseGuild? guild = await ctx.dbGuild;

        if (channel is! ITextGuildChannel) {
          throw Exception("Channel must be a text channel.");
        }

        await client.database.updateGuild(guild?.id ?? "", {
          "vbucksAlertChannelID": channel.id.toString(),
          "vbucksAlertRoleID": role?.id.toString(),
        });

        await respond(
          ctx,
          MessageBuilder.embed(
            EmbedBuilder()
              ..title = "Auto Post V-Bucks Alerts"
              ..description =
                  "V-Bucks alerts will be posted in ${channel.mention}${role != null ? " (<@&${role.id}>)" : ""} daily at 0:00 UTC."
              ..color = DiscordColor.fromHexString((await ctx.dbUser).color)
              ..timestamp = DateTime.now(),
          ),
        );
      },
    ),
    Command(
      "legendary-survivor-alerts",
      "Configure settings for auto post legendary survivor alerts.",
      (Context ctx, IChannel channel, [IRole? role]) async {
        DatabaseGuild? guild = await ctx.dbGuild;

        if (channel is! ITextGuildChannel) {
          throw Exception("Channel must be a text channel.");
        }

        await client.database.updateGuild(guild?.id ?? "", {
          "legendarySurvivorChannelID": channel.toString(),
          "legendarySurvivorRoleID": role?.toString(),
        });

        await respond(
          ctx,
          MessageBuilder.embed(
            EmbedBuilder()
              ..title = "Auto Post Legendary Survivor Alerts"
              ..description =
                  "Legendary survivor alerts will be posted in ${channel.mention}${role != null ? " (<@&${role.id}>)" : ""} daily at 0:00 UTC."
              ..color = DiscordColor.fromHexString((await ctx.dbUser).color)
              ..timestamp = DateTime.now(),
          ),
        );
      },
    ),
  ],
  checks: [guildCheck],
);
