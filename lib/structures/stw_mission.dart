class Modifier {
  String id;
  String name;
  String description;
  String imageUrl;

  Modifier({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory Modifier.fromJson(Map<String, dynamic> json) => Modifier(
        id: json["id"],
        name: json["name"] ?? json["id"],
        description: json["description"] ?? "",
        imageUrl: "https://fishstickbot.com${json["image_url"]}",
      );
}

class Reward {
  String id;
  int amount;
  bool repeatable;
  String name;
  String imagePath;
  String rarity;

  Reward({
    required this.id,
    required this.amount,
    required this.repeatable,
    required this.name,
    required this.imagePath,
    required this.rarity,
  });

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
        id: json["id"] ?? "",
        amount: json["amount"] ?? 0,
        repeatable: json["repeatable"] ?? true,
        name: json["name"] ?? json["id"],
        imagePath: "https://fishstickbot.com/${json["image_path"]}",
        rarity: json["rarity"] ?? "common",
      );
}

class STWMission {
  String id;
  bool show;
  String name;
  String imageUrl;
  String area;
  String biome;
  int powerLevel;
  bool isGroupMission;
  List<Modifier> modifiers;
  List<Reward> rewards;

  STWMission({
    required this.id,
    required this.show,
    required this.name,
    required this.imageUrl,
    required this.area,
    required this.biome,
    required this.powerLevel,
    required this.isGroupMission,
    required this.modifiers,
    required this.rewards,
  });

  factory STWMission.fromJson(Map<String, dynamic> json) => STWMission(
        id: json["id"] ?? "",
        show: json["show"] ?? true,
        name: json["missionType"] ?? json["id"],
        imageUrl: "https://fishstickbot.com/${json["image_url"]}",
        area: json["area"] ?? "",
        biome: json["biome"] ?? "",
        powerLevel: json["powerLevel"] ?? 0,
        isGroupMission: json["isGroupMission"] ?? false,
        modifiers: (json["modifiers"] as List)
            .map((e) => Modifier.fromJson(e))
            .toList(),
        rewards:
            (json["rewards"] as List).map((e) => Reward.fromJson(e)).toList(),
      );
}
