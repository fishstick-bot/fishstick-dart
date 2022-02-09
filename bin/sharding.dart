import "package:nyxx_sharding/nyxx_sharding.dart";
import "package:fishstick_dart/fishstick_dart.dart";

void main() async {
  final IShardingManager shardManager = IShardingManager.create(
    UncompiledDart("bin/fishstick_dart.dart"),
    token: Config().token,
    numProcesses: 4,
    shardsPerProcess: 2,
  );
  await shardManager.start();
}
