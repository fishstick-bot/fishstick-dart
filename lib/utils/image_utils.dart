import "package:dio/dio.dart";
import "package:fortnite/fortnite.dart" hide Client;

import "../extensions/fortnite_extensions.dart";

int reduceBy = 4;

class ImageUtils {
  late final String _apiKey;

  ImageUtils(this._apiKey);

  /// draw fortnite cosmetic
  Future<String> drawLocker({
    required List<AthenaCosmetic> cosmetics,
    required String epicname,
  }) async {
    var img = await Dio().post(
      "https://fishstickbot.com/api/locker",
      data: {
        "items": cosmetics
            .map((cosmetic) => {
                  "id": cosmetic.id,
                  "name": cosmetic.name,
                  "type": cosmetic.type,
                  "rarity": cosmetic.rarity,
                  "image": cosmetic.image,
                  "isExclusive": cosmetic.isExclusive,
                })
            .toList(),
        "epicname": epicname,
      },
      options: Options(
        headers: {
          "Authorization": _apiKey,
        },
      ),
    );

    return img.data;
  }
}

class Colors {
  static int get white => 0xFFFFFFFF;

  /// colors for fortnite rarities
  static Map<String, List<int>> get overlayColors => {
        "common": [96, 170, 58],
        "uncommon": [96, 170, 58],
        "rare": [73, 172, 242],
        "epic": [177, 91, 226],
        "legendary": [211, 120, 65],
        "marvel": [168, 53, 56],
        "dark": [179, 62, 187],
        "dc": [80, 97, 122],
        "icon": [43, 134, 135],
        "lava": [185, 102, 100],
        "frozen": [148, 215, 244],
        "shadow": [66, 64, 63],
        "starwars": [231, 196, 19],
        "slurp": [0, 233, 176],
        "platform": [117, 108, 235],
        "gaminglegends": [117, 108, 235],
      };
}
