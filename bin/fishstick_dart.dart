import "package:fishstick_dart/fishstick_dart.dart";
import "package:fishstick_dart/system_jobs/update_cosmetics_cache.dart";

void main() async {
  /// register the commands
  client.commands.addCommand(pingCommand);
  client.commands.addCommand(inviteCommand);
  client.commands.addCommand(infoCommand);
  client.commands.addCommand(helpCommand);
  client.commands.addCommand(autopostCommand);
  client.commands.addCommand(colorCommand);
  client.commands.addCommand(settingsCommand);
  client.commands.addCommand(premiumCommand);
  client.commands.addCommand(partnerCommand);
  client.commands.addCommand(blacklistCommand);
  client.commands.addCommand(loginCommand);
  client.commands.addCommand(logoutCommand);
  client.commands.addCommand(accountCommand);
  client.commands.addCommand(gameLaunchCommand);
  client.commands.addCommand(vbucksCommand);
  client.commands.addCommand(affiliateCommand);
  client.commands.addCommand(mfaCommand);
  client.commands.addCommand(afkCommand);
  client.commands.addCommand(overviewCommand);
  client.commands.addCommand(resourcesSTWCommand);

  /// start the client
  await client.start();

  final UpdateCosmeticsCacheSystemJob job = UpdateCosmeticsCacheSystemJob();
  await job.run();
}
