import "package:nyxx/nyxx.dart";
import "../fishstick_dart.dart";
import "database.dart";

class DatabaseGuild {
  /// Main database.
  // ignore: unused_field
  late final Database _database;

  /// Discord ID of the guild.
  late String id;

  late String itemShopChannelID;
  late String itemShopRoleID;

  late String freeLlamasAlertChannelID;
  late String freeLlamasAlertRoleID;

  late String vbucksAlertChannelID;
  late String vbucksAlertRoleID;

  late String legendarySurvivorChannelID;
  late String legendarySurvivorRoleID;

  late String pl160alertsChannelID;
  late String pl160alertsRoleID;

  DatabaseGuild(
    this._database, {
    required this.id,
    required this.itemShopChannelID,
    required this.itemShopRoleID,
    required this.freeLlamasAlertChannelID,
    required this.freeLlamasAlertRoleID,
    required this.vbucksAlertChannelID,
    required this.vbucksAlertRoleID,
    required this.legendarySurvivorChannelID,
    required this.legendarySurvivorRoleID,
    required this.pl160alertsChannelID,
    required this.pl160alertsRoleID,
  });

  factory DatabaseGuild.fromJson(Database db, Map<String, dynamic> json) =>
      DatabaseGuild(
        db,
        id: json["id"] as String,
        itemShopChannelID: json["itemShopChannelID"] is String
            ? json["itemShopChannelID"] as String
            : "",
        itemShopRoleID: json["itemShopRoleID"] is String
            ? json["itemShopRoleID"] as String
            : "",
        freeLlamasAlertChannelID: json["freeLlamasAlertChannelID"] is String
            ? json["freeLlamasAlertChannelID"] as String
            : "",
        freeLlamasAlertRoleID: json["freeLlamasAlertRoleID"] is String
            ? json["freeLlamasAlertRoleID"] as String
            : "",
        vbucksAlertChannelID: json["vbucksAlertChannelID"] is String
            ? json["vbucksAlertChannelID"] as String
            : "",
        vbucksAlertRoleID: json["vbucksAlertRoleID"] is String
            ? json["vbucksAlertRoleID"] as String
            : "",
        legendarySurvivorChannelID: json["legendarySurvivorChannelID"] is String
            ? json["legendarySurvivorChannelID"] as String
            : "",
        legendarySurvivorRoleID: json["legendarySurvivorRoleID"] is String
            ? json["legendarySurvivorRoleID"] as String
            : "",
        pl160alertsChannelID: json["160alertsChannelID"] is String
            ? json["160alertsChannelID"] as String
            : "",
        pl160alertsRoleID: json["160alertsRoleID"] is String
            ? json["160alertsRoleID"] as String
            : "",
      );

  Future<IChannel> getItemShopChannel() async =>
      await client.bot.fetchChannel(Snowflake(itemShopChannelID));
  Future<IChannel> get vbucksAlertChannel async =>
      await client.bot.fetchChannel(Snowflake(vbucksAlertChannelID));
  Future<IChannel> get freeLlamasAlertChannel async =>
      await client.bot.fetchChannel(Snowflake(freeLlamasAlertChannelID));
  Future<IChannel> get legendarySurvivorChannel async =>
      await client.bot.fetchChannel(Snowflake(legendarySurvivorChannelID));
  Future<IChannel> get pl160alertsChannel async =>
      await client.bot.fetchChannel(Snowflake(pl160alertsChannelID));
}
