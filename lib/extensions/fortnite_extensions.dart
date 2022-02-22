import "package:fortnite/fortnite.dart";
import "../fishstick_dart.dart";

Map<String, String> nameCache = {};
Map<String, String> descriptionCache = {};
Map<String, String> imageCache = {};
Map<String, String> rarityCache = {};
Map<String, bool> isExclusiveCache = {};
Map<String, bool> isCrewCache = {};

extension Extras on AthenaCosmetic {
  String get partialId => templateId.split(":")[1].toLowerCase();

  Iterable<Map<String, dynamic>> get searched =>
      client.cachedCosmetics.where((cosmetic) => cosmetic["id"] == partialId);

  String get name {
    if (nameCache[partialId] != null) {
      return nameCache[partialId]!;
    }

    if (searched.isEmpty) {
      return templateId.split(":")[1];
    }

    nameCache[partialId] = searched.first["name"]!;

    return nameCache[partialId]!;
  }

  String get description {
    if (descriptionCache[partialId] != null) {
      return descriptionCache[partialId]!;
    }

    if (searched.isEmpty) {
      return "";
    }

    descriptionCache[partialId] = searched.first["description"]!;

    return descriptionCache[partialId]!;
  }

  String get image {
    if (imageCache[partialId] != null) {
      return imageCache[partialId]!;
    }

    if (searched.isEmpty) {
      return "unknown";
    }

    imageCache[partialId] = searched.first["image"]!;

    return imageCache[partialId]!;
  }

  String get rarity {
    if (rarityCache[partialId] != null) {
      return rarityCache[partialId]!;
    }

    if (searched.isEmpty) {
      return "unknown";
    }

    rarityCache[partialId] = searched.first["rarity"]!;

    return rarityCache[partialId]!;
  }

  bool get isExclusive {
    if (isExclusiveCache[partialId] != null) {
      return isExclusiveCache[partialId]!;
    }

    if (searched.isEmpty) {
      return false;
    }

    isExclusiveCache[partialId] = searched.first["isExclusive"]!;

    return isExclusiveCache[partialId]!;
  }

  bool get isCrew {
    if (isCrewCache[partialId] != null) {
      return isCrewCache[partialId]!;
    }

    if (searched.isEmpty) {
      return false;
    }

    isCrewCache[partialId] = searched.first["isCrew"]!;

    return isCrewCache[partialId]!;
  }
}
