class STWResearch {
  late int fortitude;
  late int resistance;
  late int offense;
  late int tech;

  STWResearch(this.fortitude, this.resistance, this.offense, this.tech);

  factory STWResearch.fromJson(Map<String, dynamic> json) {
    return STWResearch(
      json["fortitude"] != null
          ? json["fortitude"] is int
              ? json["fortitude"]
              : 0
          : 0,
      json["resistance"] != null
          ? json["resistance"] is int
              ? json["resistance"]
              : 0
          : 0,
      json["offense"] != null
          ? json["offense"] is int
              ? json["offense"]
              : 0
          : 0,
      json["tech"] != null
          ? json["tech"] is int
              ? json["tech"]
              : 0
          : 0,
    );
  }
}
