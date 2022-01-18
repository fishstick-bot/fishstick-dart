// ignore_for_file: annotate_overrides, overridden_fields

import "package:fortnite/fortnite.dart";

class STWSurvivorSquadPreset extends SurvivorSquadPreset {
  late String name;

  List<String> characterIds;
  List<String> squadIds;
  List<int> slotIndices;

  STWSurvivorSquadPreset({
    required this.name,
    required this.characterIds,
    required this.squadIds,
    required this.slotIndices,
  }) : super(
          characterIds: characterIds,
          squadIds: squadIds,
          slotIndices: slotIndices,
        );

  factory STWSurvivorSquadPreset.fromJson(Map<String, dynamic> json) =>
      STWSurvivorSquadPreset(
        name: json["name"] is String ? json["name"] : "",
        characterIds: (json["characterIds"] as List<dynamic>)
            .map((e) => e is String ? e : "")
            .toList(),
        squadIds: (json["squadIds"] as List<dynamic>)
            .map((e) => e is String ? e : "")
            .toList(),
        slotIndices: (json["slotIndices"] as List<dynamic>)
            .map((e) => e is int ? e : int.tryParse(e) ?? 0)
            .toList(),
      );

  @override
  Map<String, dynamic> toJson() => {
        "name": name,
        "characterIds": characterIds,
        "squadIds": squadIds,
        "slotIndices": slotIndices,
      };
}
