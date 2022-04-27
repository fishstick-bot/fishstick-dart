import "package:nyxx_sharding/nyxx_sharding.dart";
import "package:fishstick_dart/fishstick_dart.dart";

void main() async {
  final IShardingManager shardManager = IShardingManager.create(
    Config().developmentMode
        ? UncompiledDart("bin/fishstick_dart.dart")
        : Executable("build/bot.exe"),
    token: Config().token,
    // maxGuildsPerProcess: 2000,
    // maxGuildsPerShard: 1000,
    numProcesses: Config().developmentMode ? 1 : 6,
    shardsPerProcess: Config().developmentMode ? 1 : 2,
  );

  /// START THE SHARD MANAGER
  await shardManager.start();
}
