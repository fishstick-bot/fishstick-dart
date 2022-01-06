import "package:fishstick_dart/fishstick_dart.dart";

void main() async {
  /// register the commands
  client.commands.registerChild(pingCommand);
  client.commands.registerChild(inviteCommand);
  client.commands.registerChild(premiumCommand);
  client.commands.registerChild(partnerCommand);

  /// start the client
  await client.start();
}
