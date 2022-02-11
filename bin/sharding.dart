import "package:nyxx_sharding/nyxx_sharding.dart";
import "package:fishstick_dart/fishstick_dart.dart";

void main() async {
  final IShardingManager shardManager = IShardingManager.create(
    Config().developmentMode
        ? UncompiledDart("bin/fishstick_dart.dart")
        : Executable("build/bot.exe"),
    token: Config().token,
    numProcesses: Config().developmentMode ? 1 : 5,
    shardsPerProcess: Config().developmentMode ? 1 : 3,
  );
  await shardManager.start();
}
