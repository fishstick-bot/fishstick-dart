import "package:fishstick_dart/fishstick_dart.dart";

void main() async {
  /// register the commands
  client.commands.registerChild(pingCommand);
  client.commands.registerChild(inviteCommand);
  client.commands.registerChild(infoCommand);
  client.commands.registerChild(helpCommand);
  client.commands.registerChild(autopostCommand);
  client.commands.registerChild(colorCommand);
  client.commands.registerChild(settingsCommand);
  client.commands.registerChild(premiumCommand);
  client.commands.registerChild(partnerCommand);
  client.commands.registerChild(blacklistCommand);
  client.commands.registerChild(loginCommand);
  client.commands.registerChild(logoutCommand);

  /// start the client
  await client.start();
}
