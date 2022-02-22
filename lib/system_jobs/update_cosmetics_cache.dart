import "dart:convert";
import "package:http/http.dart";
import "../fishstick_dart.dart";
import "../resources/exclusives.dart";
import "../resources/crew.dart";

class UpdateCosmeticsCacheSystemJob {
  final String name = "update_cosmetics_cache";

  final Duration runDuration = Duration(hours: 6);

  /// run the task
  Future<void> run() async {
    try {
      int time = DateTime.now().millisecondsSinceEpoch;
      client.logger.info("[TASK:$name] starting...");

      var rawres =
          await get(Uri.parse("https://fortnite-api.com/v2/cosmetics/br"));

      List<dynamic> res;
      if (rawres.statusCode >= 200 || rawres.statusCode < 300) {
        res = jsonDecode(rawres.body)["data"] as List;
      } else {
        throw Exception(rawres.body);
      }

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
                "isExclusive":
                    exclusives.contains(c["id"].toString().toLowerCase()),
                "isCrew": crew.contains(c["id"].toString().toLowerCase()),
              })
          .toList();

      final cosmetics = await client.database.cosmetics.find().toList();
      client.cachedCosmetics = cosmetics;

      for (final c in res) {
        bool _exists = cosmetics
            .where((cosm) => cosm["id"] == c["id"].toString().toLowerCase())
            .isNotEmpty;
        if (_exists) continue;

        try {
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
            "isExclusive":
                exclusives.contains(c["id"].toString().toLowerCase()),
            "isCrew": crew.contains(c["id"].toString().toLowerCase()),
          });
        } catch (e) {
          // ignore
        }
        client.logger
            .info("[TASK:$name] added cosmetic to database: ${c["name"]}");
      }

      client.logger.info(
          "[TASK:$name] finished in ${DateTime.now().millisecondsSinceEpoch - time}ms");
    } catch (e) {
      client.logger.shout(
          "[TASK:$name] An unexpected error occured retrying in 30seconds: $e");
      await Future.delayed(Duration(seconds: 30), () async => await run());
    }
    return;
  }
}
