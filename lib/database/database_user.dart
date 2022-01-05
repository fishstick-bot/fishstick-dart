import "database.dart";
import "../structures/epic_account.dart";
import "../structures/premium.dart";
import "../structures/premium_tier.dart";
import "../structures/auto_subscriptions.dart";
import "../structures/privacy.dart";
import "../structures/user_blacklist.dart";

class DatabaseUser {
  /// Main database.
  // ignore: unused_field
  late final Database _database;

  /// Discord ID of the user.
  late String id;

  /// Username of the user.
  late String name;

  /// Selected account's id of the user.
  late String selectedAccount;

  /// Linked epic accounts of user.
  late List<EpicAccount> linkedAccounts;

  /// Premium status of the user.
  late Premium premium;

  /// Bonus epic account add limit of the user.
  late int bonusAccLimit;

  /// Auto subscriptions of the user.
  late AutoSubscriptions autoSubscriptions;

  /// should user receive dm notifications?
  late bool dmNotifications;

  /// hex color for user.
  late String color;

  /// privacy enum for user.
  late Privacy privacyEnum;

  /// privacy settings for user.
  late int privacy;

  /// user blacklist.
  late Blacklist blacklisted;

  /// Sessions.
  late Map<String, dynamic> sessions;

  /// [DatabaseUser] constructor.
  DatabaseUser(
    _database, {
    required this.id,
    required this.name,
    required this.selectedAccount,
    required this.linkedAccounts,
    required this.premium,
    required this.bonusAccLimit,
    required this.autoSubscriptions,
    required this.dmNotifications,
    required this.color,
    required this.privacyEnum,
    required this.privacy,
    required this.blacklisted,
    required this.sessions,
  });

  /// [DatabaseUser] constructor from json.
  factory DatabaseUser.fromJson(
    Database db,
    Map<String, dynamic> json,
  ) {
    json["linkedAccounts"] ??= [];

    return DatabaseUser(
      db,
      id: json["id"],
      name: json["name"] ?? "",
      selectedAccount: json["selectedAccount"] ?? "",
      linkedAccounts: json["linkedAccounts"] is List<dynamic>
          ? List<EpicAccount>.from(
              json["linkedAccounts"].map((x) => EpicAccount.fromJson(x)))
          : [],
      premium: Premium.fromJson(json["premium"]),
      bonusAccLimit: json["bonusAccLimit"] is int ? json["bonusAccLimit"] : 0,
      autoSubscriptions: AutoSubscriptions.fromJson(json["autoSubscriptions"]),
      dmNotifications: json["dmNotifications"] ?? true,
      color: json["color"] ?? "#09b7d6",
      privacyEnum: Privacy.values[json["privacy"] is int ? json["privacy"] : 0],
      privacy: json["privacy"] is int ? json["privacy"] : 0,
      blacklisted: Blacklist.fromJson(json["blacklisted"]),
      sessions:
          json["sessions"] is Map<String, dynamic> ? json["sessions"] : {},
    );
  }

  /// is the user blacklisted?
  bool get isBanned => blacklisted.value;

  /// is the user premium
  bool get isPremium =>
      premium.tierEnum == PremiumTier.premium ||
      premium.tierEnum == PremiumTier.partner;
}
