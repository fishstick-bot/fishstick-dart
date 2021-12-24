import "dart:async";
import "package:nyxx/nyxx.dart";
import "../config.dart";

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
        initialPresence: PresenceBuilder.of(
          activity: ActivityBuilder.game("/help"),
          status: UserStatus.online,
        ),
        dispatchRawShardEvent: true,
      ),
      useDefaultLogger: false,
    )
      ..registerPlugin(Logging())
      ..registerPlugin(CliIntegration())
      ..registerPlugin(IgnoreExceptions());

    _bot.onReady.listen((_) {
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
