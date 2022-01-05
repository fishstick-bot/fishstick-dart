import "stw_research.dart";
import "stw_hero_loadout_preset.dart";
import "stw_survivor_squad_preset.dart";

class EpicAccount {
  late String accountId;
  late String deviceId;
  late String secret;

  late String displayName;
  late String avatar;

  late STWResearch cachedResearchValues;

  late int dailiesLastRefresh;
  late int lastDailyRewardClaim;
  late int lastFreeLlamasClaim;

  late num powerLevel;

  /// not used for now.
  late List<STWHeroLoadoutPreset> savedHeroLoadouts;

  late List<STWSurvivorSquadPreset> savedSurvivorSquads;

  EpicAccount({
    required this.accountId,
    required this.deviceId,
    required this.secret,
    required this.displayName,
    required this.avatar,
    required this.cachedResearchValues,
    required this.dailiesLastRefresh,
    required this.lastDailyRewardClaim,
    required this.lastFreeLlamasClaim,
    required this.powerLevel,
    required this.savedHeroLoadouts,
    required this.savedSurvivorSquads,
  });

  factory EpicAccount.fromJson(Map<String, dynamic> json) {
    return EpicAccount(
      accountId: json["accountId"] is String ? json["accountId"] : "",
      deviceId: json["deviceId"] is String ? json["deviceId"] : "",
      secret: json["secret"] is String ? json["secret"] : "",
      displayName: json["displayName"] is String ? json["displayName"] : "",
      avatar: json["avatar"] is String ? json["avatar"] : "",
      cachedResearchValues: json["cachedResearchValues"] is Map<String, dynamic>
          ? STWResearch.fromJson(json["cachedResearchValues"])
          : STWResearch(0, 0, 0, 0),
      dailiesLastRefresh:
          json["dailiesLastRefresh"] is int ? json["dailiesLastRefresh"] : 0,
      lastDailyRewardClaim: json["lastDailyRewardClaim"] is int
          ? json["lastDailyRewardClaim"]
          : 0,
      lastFreeLlamasClaim:
          json["lastFreeLlamasClaim"] is int ? json["lastFreeLlamasClaim"] : 0,
      powerLevel: json["powerLevel"] is num ? json["powerLevel"] : 0,
      savedHeroLoadouts: [], // not used for now
      savedSurvivorSquads: json["savedSurvivorSquads"] is List<dynamic>
          ? List<STWSurvivorSquadPreset>.from(json["savedSurvivorSquads"]
              .map((x) => STWSurvivorSquadPreset.fromJson(x)))
          : [],
    );
  }
}
