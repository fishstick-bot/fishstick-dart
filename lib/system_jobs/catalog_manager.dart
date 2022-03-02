import "dart:convert";
import "package:http/http.dart";
import "../fishstick_dart.dart";
import "../structures/br_catalog.dart";

class CatalogManagerSystemJob {
  final String name = "catalog_manager";

  final Duration runDuration = Duration(minutes: 15);

  late BRCatalog brCatalog;

  /// run the task
  Future<void> run() async {
    try {
      int time = DateTime.now().millisecondsSinceEpoch;
      client.logger.info("[TASK:$name] starting...");

      var rawres =
          await get(Uri.parse("https://fishstickbot.com/api/shop.json"));

      Map<String, dynamic> res;
      if (rawres.statusCode >= 200 || rawres.statusCode < 300) {
        res = jsonDecode(rawres.body) as Map<String, dynamic>;
      } else {
        throw Exception(rawres.body);
      }

      brCatalog = BRCatalog(
        res["data"],
        date: DateTime.parse(res["date"]),
        uid: res["uid"],
      );

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
