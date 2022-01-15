import "package:dio/dio.dart";
import "../fishstick_dart.dart";

class UpdateCosmeticsCacheSystemJob {
  /// run the task
  Future<void> run() async {
    try {
      final res =
          (await Dio().get("https://fortnite-api.com/v2/cosmetics/br")).data;
      client.logger.info(res);

      /// TODO
    } on DioError catch (e) {
      client.logger.shout(
          "[TASK:update_cosmetics_cache] An unexpected error occured retrying in 30seconds: ${e.response?.data}");
      await Future.delayed(Duration(seconds: 30), () async => await run());
    }
    return;
  }
}
