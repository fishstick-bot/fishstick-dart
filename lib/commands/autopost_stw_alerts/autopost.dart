import "package:nyxx_commands/nyxx_commands.dart";
import "../../utils/utils.dart";
import "vbucks_alerts.dart";
import "legendary_survivor_alerts.dart";

final Group autopostCommand = Group(
  "autopost",
  "Configure auto post settings.",
  children: [
    autopostVbucksAlertsCommand,
    autopostLegendarySurvivorAlertsCommand,
  ],
  checks: [guildCheck],
);
