import "package:dio/dio.dart";
import "../fishstick_dart.dart";

class UpdateCosmeticsCacheSystemJob {
  final String name = "update_cosmetics_cache";

  /// run the task
  Future<void> run() async {
    try {
      int time = DateTime.now().millisecondsSinceEpoch;
      client.logger.info("[TASK:$name] starting...");

      final res = ((await Dio().get("https://fortnite-api.com/v2/cosmetics/br"))
          .data["data"] as List);

      client.cachedCosmetics = res
          .map((c) => {
                "id": c["id"].toString().toLowerCase(),
                "name": c["name"],
                "description": c["description"],
                "type": c["type"]?["value"] ?? "unknown",
                "rarity": c["rarity"]?["value"] ?? "unknown",
                "series": c["series"]?["value"] ?? "unknown",
                "set": c["set"]?["value"] ?? "unknown",
                "image": c["images"]["icon"] ?? c["images"]["smallIcon"] ?? "",
                "displayAssetPath": c["displayAssetPath"] ?? "",
                "added": DateTime.tryParse(c["added"]) ?? DateTime.now(),
              })
          .toList();

      final cosmetics = await client.database.cosmetics.find().toList();
      client.cachedCosmetics = cosmetics;

      for (final c in res) {
        bool _exists = cosmetics
                .where((cosm) => cosm["id"] == c["id"].toString().toLowerCase())
                .length ==
            1;
        if (_exists) continue;

        await client.database.cosmetics.insert({
          "id": c["id"].toString().toLowerCase(),
          "name": c["name"],
          "description": c["description"],
          "type": c["type"]?["value"] ?? "unknown",
          "rarity": c["rarity"]?["value"] ?? "unknown",
          "series": c["series"]?["value"] ?? "unknown",
          "set": c["set"]?["value"] ?? "unknown",
          "image": c["images"]["icon"] ?? c["images"]["smallIcon"] ?? "",
          "displayAssetPath": c["displayAssetPath"] ?? "",
          "added": DateTime.tryParse(c["added"]) ?? DateTime.now(),
        });
        client.logger
            .info("[TASK:$name] added cosmetic to database: ${c["name"]}");
      }

      client.logger.info(
          "[TASK:$name] finished in ${DateTime.now().millisecondsSinceEpoch - time}ms");
    } on DioError catch (e) {
      client.logger.shout(
          "[TASK:$name] An unexpected error occured retrying in 30seconds: ${e.response?.data}");
      await Future.delayed(Duration(seconds: 30), () async => await run());
    }
    return;
  }
}
