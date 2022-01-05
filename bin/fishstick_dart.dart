import "package:fishstick_dart/fishstick_dart.dart";

void main() async {
  /// register the commands
  client.commands.registerChild(pingCommand);

  /// start the client
  await client.start();
}
