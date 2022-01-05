class AutoSubscriptions {
  late bool dailyRewards;
  late bool freeLlamas;
  late bool collectResearchPoints;

  /// can be fortitude , resistance , offense , tech , all , none.
  late String research;

  AutoSubscriptions({
    required this.dailyRewards,
    required this.freeLlamas,
    required this.collectResearchPoints,
    required this.research,
  });

  factory AutoSubscriptions.fromJson(Map<String, dynamic> json) =>
      AutoSubscriptions(
        dailyRewards:
            json["dailyRewards"] is bool ? json["dailyRewards"] : false,
        freeLlamas: json["freeLlamas"] is bool ? json["freeLlamas"] : false,
        collectResearchPoints: json["collectResearchPoints"] is bool
            ? json["collectResearchPoints"]
            : false,
        research: json["research"] is String ? json["research"] : "none",
      );
}
