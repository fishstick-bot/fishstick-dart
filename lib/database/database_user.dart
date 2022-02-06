import "package:nyxx/nyxx.dart" hide PremiumTier, ClientOptions;
import "package:fortnite/fortnite.dart";
import "database.dart";
import "../structures/epic_account.dart";
import "../structures/premium.dart";
import "../structures/premium_tier.dart";
import "../structures/auto_subscriptions.dart";
import "../structures/privacy.dart";
import "../structures/user_blacklist.dart";
import "../utils/utils.dart";

class DatabaseUser {
  /// Main database.
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

  /// fortnite client for the user.
  late Client fnClient;

  /// [DatabaseUser] constructor.
  DatabaseUser(
    this._database, {
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
    json["linkedEpicAccounts"] ??= [];

    if ((json["linkedEpicAccounts"] as List<dynamic>).length > 25) {
      json["linkedEpicAccounts"] =
          (json["linkedEpicAccounts"] as List<dynamic>).take(25).toList();
    }

    return DatabaseUser(
      db,
      id: json["id"] as String,
      name: "",
      selectedAccount: json["selectedAccount"] == null
          ? ""
          : json["selectedAccount"] is String
              ? json["selectedAccount"] as String
              : "",
      linkedAccounts: List<EpicAccount>.from((json["linkedEpicAccounts"])
          .map((x) => EpicAccount.fromJson(x as Map<String, dynamic>))),
      premium: Premium.fromJson(json["premium"] as Map<String, dynamic>),
      bonusAccLimit:
          json["bonusAccLimit"] is int ? json["bonusAccLimit"] as int : 0,
      autoSubscriptions: AutoSubscriptions.fromJson(
          json["autoSubscriptions"] as Map<String, dynamic>),
      dmNotifications: json["dmNotifications"] == null
          ? false
          : json["dmNotifications"] as bool,
      color: json["color"] == null
          ? ""
          : json["color"] is String
              ? json["color"] as String
              : "#34ebe5",
      privacyEnum:
          Privacy.values[json["privacy"] is int ? json["privacy"] as int : 0],
      privacy: json["privacy"] is int ? json["privacy"] as int : 0,
      blacklisted: json["blacklisted"] == null
          ? Blacklist.fromJson({})
          : Blacklist.fromJson(json["blacklisted"] as Map<String, dynamic>),
      sessions: json["sessions"] is Map<String, dynamic>
          ? json["sessions"] as Map<String, dynamic>
          : {},
    );
  }

  /// is user from discord?
  bool get isDiscordUser => id.length >= 16;

  /// is the user blacklisted?
  bool get isBanned => blacklisted.value;

  /// is the user premium
  bool get isPremium {
    if (isPartner) {
      return true;
    }

    if (premium.tierEnum == PremiumTier.premium ||
        premium.tierEnum == PremiumTier.partner) {
      if (premium.until.millisecondsSinceEpoch >
          DateTime.now().millisecondsSinceEpoch) {
        return true;
      }
    }

    return false;
  }

  /// is the user partner
  bool get isPartner => premium.tierEnum == PremiumTier.partner;

  /// get accounts limit
  int get accountsLimit {
    int limit = 3;

    if (isPremium) {
      limit = 15;
    } else if (isPartner) {
      limit = 25;
    }

    return limit;
  }

  /// revoke premium of user.
  Future<void> revokePremium(IUser responsiblePartner, IUser targetUser) async {
    premium = Premium(
      tierEnum: PremiumTier.regular,
      until: DateTime.utc(1900, 1, 1),
      tier: 0,
      grantedBy: responsiblePartner.id.toString(),
    );

    await _database.updateUser(id, {
      "premium": premium.toJson(),
    });

    return await notifyRevokePremiumEvent(
      user: targetUser,
      partner: responsiblePartner,
    );
  }

  /// grant premium to user.
  Future<void> grantPremium(
      IUser responsiblePartner, IUser targetUser, Duration duration) async {
    if (premium.until.millisecondsSinceEpoch <
        DateTime.now().millisecondsSinceEpoch) {
      premium.until = DateTime.now();
    }

    premium = Premium(
      tierEnum: PremiumTier.premium,
      until: DateTime.fromMillisecondsSinceEpoch(
          premium.until.millisecondsSinceEpoch + duration.inMilliseconds),
      tier: 1,
      grantedBy: responsiblePartner.id.toString(),
    );

    await _database.updateUser(id, {
      "premium": premium.toJson(),
    });

    return await notifyGrantPremiumEvent(
      user: targetUser,
      partner: responsiblePartner,
      duration: duration,
    );
  }

  /// revoke partner of user.
  Future<void> updatePartnerStatus(
      IUser responsibleAdmin, IUser targetUser, bool grant) async {
    premium = Premium(
      grantedBy: responsibleAdmin.id.toString(),
      tier: grant ? 2 : 0,
      tierEnum: grant ? PremiumTier.partner : PremiumTier.regular,
      until: grant ? DateTime.utc(1900, 1, 1) : DateTime.utc(3000, 1, 1),
    );

    return _database.updateUser(id, {
      "premium": premium.toJson(),
    });
  }

  /// blacklist a user
  Future<void> blacklist(String reason) async {
    blacklisted = Blacklist(
      value: true,
      blacklistedOn: DateTime.now(),
      reason: reason,
    );

    return await _database.updateUser(id, {
      "blacklisted": blacklisted.toJson(),
    });
  }

  /// unblacklist a user
  Future<void> unblacklist() async {
    blacklisted = Blacklist(
      value: false,
      blacklistedOn: DateTime.now(),
      reason: "",
    );

    return await _database.updateUser(id, {
      "blacklisted": blacklisted.toJson(),
    });
  }

  // enable mentions privacy
  void enableMentionsPrivacy() {
    privacyEnum = Privacy.values[1];
    privacy = 1;
  }

  // disable mentions privacy
  void disableMentionsPrivacy() {
    privacyEnum = Privacy.values[0];
    privacy = 0;
  }

  /// add an account to user
  Future<void> addAccount(EpicAccount acc) async {
    linkedAccounts.add(acc);

    await _database.updateUser(id, {
      "linkedEpicAccounts": linkedAccounts.map((x) => x.toJson()).toList(),
    });
  }

  /// remove an account from user
  Future<void> removeAccount(EpicAccount acc) async {
    linkedAccounts =
        linkedAccounts.where((a) => a.accountId != acc.accountId).toList();

    await _database.updateUser(id, {
      "linkedEpicAccounts": linkedAccounts.map((x) => x.toJson()).toList(),
    });
  }

  /// update current account
  Future<void> updateActiveAccount() async {
    linkedAccounts[linkedAccounts.indexOf(linkedAccounts.firstWhere(
        (a) => a.accountId == activeAccount.accountId))] = activeAccount;
    await _database.updateUser(id, {
      "linkedEpicAccounts": linkedAccounts.map((x) => x.toJson()).toList(),
    });
  }

  /// set active account
  Future<void> setActiveAccount(String accId) async {
    selectedAccount = accId;

    await _database.updateUser(id, {
      "selectedAccount": selectedAccount,
    });
  }

  /// get user's active account
  EpicAccount get activeAccount {
    return linkedAccounts.firstWhere((x) => x.accountId == selectedAccount);
  }

  /// get the user's fortnite client.
  Client fnClientSetup() {
    if (linkedAccounts.isEmpty) {
      throw Exception(
          "You don't have any epic accounts linked to your account.");
    }

    var found = linkedAccounts.where((a) => a.accountId == selectedAccount);

    if (found.isEmpty) {
      throw Exception(
          "You don't have any epic accounts linked to your account.");
    }

    fnClient = Client(
      options: ClientOptions(
        deviceAuth: found.first.deviceAuth,
        logLevel: Level.INFO,
      ),
      overrideSession: sessions[selectedAccount] == null
          ? ""
          : sessions[selectedAccount] is String
              ? sessions[selectedAccount] as String
              : "",
    );

    fnClient.onSessionUpdate.listen((Client update) async {
      sessions[update.accountId] = update.session;
      await _database.updateUser(id, {
        "sessions": sessions,
      });
    });

    fnClient.onInvalidAccount.listen((event) async {
      linkedAccounts.removeWhere((a) => a.accountId == event.accountId);
      await _database.updateUser(id, {
        "linkedEpicAccounts": linkedAccounts.map((x) => x.toJson()).toList(),
        "selectedAccount":
            linkedAccounts.isEmpty ? "" : linkedAccounts.first.accountId,
      });
    });

    return fnClient;
  }
}
