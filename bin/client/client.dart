import 'dart:async';
import 'dart:io';
import 'package:nyxx/nyxx.dart';
import '../config.dart';

class Client {
  /// Configuration for the client
  late final Config _config = Config();

  /// The nyxx client
  late INyxxWebsocket _bot;

  Client() {
    _bot = NyxxFactory.createNyxxWebsocket(
      _config.token,
      GatewayIntents.allUnprivileged,
      options: ClientOptions(
          // initialPresence: PresenceBuilder.of(
          //   activity: ActivityType.game,
          //   status: UserStatus.online,
          // ),
          ),
      useDefaultLogger: false,
    )
      ..registerPlugin(Logging())
      // ..registerPlugin(CliIntegration())
      ..registerPlugin(IgnoreExceptions());

    _bot.eventsWs.onReady.listen((event) {
      Timer.periodic(Duration(seconds: 5), (timer) {
        print("${_bot.guilds.length} Guilds");
      });
    });
  }

  /// Start the client.
  /// This will connect to the bot to discord
  Future<void> start() async {
    await _bot.connect();
  }
}
