import "package:fortnite/fortnite.dart";

class Player {
  String accountId;
  String displayName;

  Player(this.accountId, this.displayName);
}

class Friend extends Player {
  FriendsManager manager;

  Map<String, String> connections;

  String alias;

  DateTime created;

  Friend(
    this.manager, {
    required String accountId,
    required String displayName,
    required this.connections,
    required this.alias,
    required this.created,
  }) : super(
          accountId,
          displayName,
        );

  bool eligibleToGift() =>
      Duration(
          milliseconds: DateTime.now().millisecondsSinceEpoch -
              created.millisecondsSinceEpoch) >
      Duration(days: 2);
}

class FriendsManager {
  final Client _fnclient;

  Map<String, Friend> friends = {};

  FriendsManager(this._fnclient);

  Future<void> init() async {
    var res = await _fnclient.get(
            "https://friends-public-service-prod.ol.epicgames.com/friends/api/v1/${_fnclient.accountId}/summary?displayNames=true")
        as Map<String, dynamic>;

    var _friends = res["friends"] as List<dynamic>;

    for (final f in _friends) {
      friends[f["accountId"]] = Friend(
        this,
        accountId: f["accountId"],
        displayName: f["displayName"] ?? "",
        connections: f["connections"] ?? {},
        alias: f["alias"] ?? "",
        created: DateTime.parse(f["created"]),
      );
    }
  }

  Future<void> clearFriendList() async {
    await _fnclient.send(
      method: "DELETE",
      url:
          "https://friends-public-service-prod.ol.epicgames.com/friends/api/v1/${_fnclient.accountId}/friends",
    );
  }
}
