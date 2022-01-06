class Blacklist {
  late DateTime blacklistedOn;
  late bool value;
  late String reason;

  Blacklist({
    required this.blacklistedOn,
    required this.value,
    required this.reason,
  });

  factory Blacklist.fromJson(Map<String, dynamic> json) => Blacklist(
        blacklistedOn:
            json["on"] is DateTime ? json["on"] : DateTime.utc(1900, 1, 1),
        value: json["value"] is bool ? json["value"] : false,
        reason: json["reason"] is String ? json["reason"] : "",
      );
}
