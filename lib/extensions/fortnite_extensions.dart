import "package:fortnite/fortnite.dart";
import "../fishstick_dart.dart";

extension Extras on AthenaCosmetic {
  Iterable<Map<String, dynamic>> get searched => client.cachedCosmetics.where(
      (cosmetic) => cosmetic["id"] == templateId.split(":")[1].toLowerCase());

  String get name {
    if (searched.isEmpty) {
      return templateId.split(":")[1];
    }

    return searched.first["name"] ?? templateId.split(":")[1];
  }

  String get description {
    if (searched.isEmpty) {
      return "";
    }

    return searched.first["description"] ?? "";
  }

  String get image {
    if (searched.isEmpty) {
      return "";
    }

    return searched.first["image"] ?? "";
  }

  String get imagePath =>
      "cosmetics/${type.toLowerCase()}/${templateId.split(":")[1].toLowerCase()}.png";

  String get rarity {
    if (searched.isEmpty) {
      return "";
    }

    return searched.first["rarity"] ?? "";
  }
}
