import "dart:convert";
import "package:fishstick_dart/database/database_guild.dart";
import "package:http/http.dart" hide Client;
import "package:nyxx/nyxx.dart";
import "../client/client.dart";
import "../structures/stw_mission.dart";

class STWMissionsSystemJob {
  final String name = "stw_missions";

  late List<STWMission> missions;

  Client client;

  STWMissionsSystemJob(this.client);

  /// run the task
  Future<void> run() async {
    try {
      int time = DateTime.now().millisecondsSinceEpoch;
      client.logger.info("[TASK:$name] starting...");

      var rawres =
          await get(Uri.parse("https://fishstickbot.com/api/missions"));

      Map<String, dynamic> res;
      if (rawres.statusCode >= 200 || rawres.statusCode < 300) {
        res = jsonDecode(rawres.body) as Map<String, dynamic>;
      } else {
        throw Exception(rawres.body);
      }

      missions = res["missions"]
          .map<STWMission>((m) => STWMission.fromJson(m))
          .toList();

      final vbucksMissions = missions.where((m) =>
          m.rewards.where((r) => r.name == "V-Bucks Voucher").isNotEmpty);

      final legendarySurvivorMissions = missions.where((m) =>
          m.rewards.where((r) => r.name == "Legendary Survivor").isNotEmpty);

      final totalVbucks = vbucksMissions
          .map((m) =>
              m.rewards.firstWhere((r) => r.name == "V-Bucks Voucher").amount)
          .toList()
          .reduce((value, element) => value + element);

      final totalLegendarySurvivors = legendarySurvivorMissions
          .map((m) => m.rewards
              .firstWhere((r) => r.name == "Legendary Survivor")
              .amount)
          .toList()
          .reduce((value, element) => value + element);

      var _stream = client.database.guilds.find();

      await for (final g in _stream) {
        if (g["id"] == null) continue;
        var guild = DatabaseGuild.fromJson(client.database, g);

        if (vbucksMissions.isNotEmpty && guild.vbucksAlertChannelID != "") {
          try {
            final EmbedBuilder embed = EmbedBuilder()
              ..title = "Today's V-Bucks Alerts"
              ..color = DiscordColor.blue
              ..footer =
                  (EmbedFooterBuilder()..text = "$totalVbucks V-Bucks today")
              ..timestamp = DateTime.now()
              ..description = vbucksMissions
                  .map((m) =>
                      "**[${m.powerLevel}] ${m.name}**\n${m.biome} - ${m.area}\n${m.rewards.map((r) => "${r.repeatable ? "**" : ""}${r.amount}x ${r.name}${r.repeatable ? "**" : ""}").join("\n")}")
                  .join("\n");

            final channel = await client.bot
                    .fetchChannel(guild.vbucksAlertChannelID.toSnowflake())
                as ITextGuildChannel;

            await channel.sendMessage(MessageBuilder.embed(embed)
              ..content = guild.vbucksAlertRoleID != ""
                  ? "<@${guild.vbucksAlertRoleID}> New V-Bucks Alerts!"
                  : "New V-Bucks Alerts!");
          } catch (e) {
            client.logger.warning(
                "[TASK:$name] failed to send vbucks alert for guild ${guild.id}: $e");
          }
        }

        if (legendarySurvivorMissions.isNotEmpty &&
            guild.legendarySurvivorChannelID != "") {
          try {
            final EmbedBuilder embed = EmbedBuilder()
              ..title = "Today's Legendary Survivor Alerts"
              ..color = DiscordColor.blue
              ..footer = (EmbedFooterBuilder()
                ..text = "$totalLegendarySurvivors Legendary Survivors today")
              ..timestamp = DateTime.now()
              ..description = legendarySurvivorMissions
                  .map((m) =>
                      "**[${m.powerLevel}] ${m.name}**\n${m.biome} - ${m.area}\n${m.rewards.map((r) => "${r.repeatable ? "**" : ""}${r.amount}x ${r.name}${r.repeatable ? "**" : ""}").join("\n")}")
                  .join("\n");

            final channel = await client.bot.fetchChannel(
                    guild.legendarySurvivorChannelID.toSnowflake())
                as ITextGuildChannel;

            await channel.sendMessage(MessageBuilder.embed(embed)
              ..content = guild.legendarySurvivorRoleID != ""
                  ? "<@${guild.legendarySurvivorRoleID}> New Legendary Survivor Alerts!"
                  : "New Legendary Survivor Alerts!");
          } catch (e) {
            client.logger.warning(
                "[TASK:$name] failed to send legendary survivor alert for guild ${guild.id}: $e");
          }
        }
      }

      client.logger.info(
          "[TASK:$name] finished in ${DateTime.now().millisecondsSinceEpoch - time}ms");
    } catch (e) {
      client.logger.shout(
          "[TASK:$name] An unexpected error occured retrying in 30seconds: $e");
      await Future.delayed(Duration(seconds: 30), () async => await run());
    }
    return;
  }
}
