import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_guild.dart";
import "../../extensions/context_extensions.dart";
import "../../utils/utils.dart";
import "../../fishstick_dart.dart";

final ChatCommand autopostVbucksAlertsCommand = ChatCommand(
  "vbucks-alerts",
  "Configure settings for auto post vbucks alerts.",
  Id(
    "autopost_vbucks_alerts_command",
    (
      IContext ctx,
      @Description("The channel to post in.") ITextGuildChannel channel, [
      @Description("The role to mention with the post.") IRole? role,
    ]) async {
      DatabaseGuild? guild = await ctx.dbGuild;

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
            ..footer = (EmbedFooterBuilder()..text = "Guild ${guild?.id ?? ""}")
            ..timestamp = DateTime.now(),
        ),
      );
    },
  ),
);
