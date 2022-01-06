import "premium_tier.dart";

class Premium {
  late DateTime until;
  late PremiumTier tierEnum;
  late int tier;
  late String grantedBy;

  Premium({
    required this.until,
    required this.tierEnum,
    required this.tier,
    required this.grantedBy,
  });

  factory Premium.fromJson(Map<String, dynamic> json) => Premium(
        until: json["until"] is DateTime
            ? json["until"]
            : DateTime.utc(1900, 1, 1),
        tierEnum: PremiumTier.values[json["tier"] is int ? json["tier"] : 0],
        tier: json["tier"] is int ? json["tier"] : 0,
        grantedBy: json["granted_by"] is String ? json["granted_by"] : "",
      );

  Map<String, dynamic> toJson() {
    return {
      "until": until,
      "tier": tier,
      "granted_by": grantedBy,
    };
  }
}
