import "dart:io" show Platform, ProcessInfo;

import "package:dio/dio.dart";

import "package:nyxx/nyxx.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "package:fortnite/fortnite.dart";

import "package:encrypt/encrypt.dart";

import "../database/database_user.dart";

import "../extensions/context_extensions.dart";
import "../extensions/fortnite_extensions.dart";

import "../fishstick_dart.dart";

RegExp numberFormatRegex = RegExp(r"(?<=\d)(?=(\d{3})+(?!\d))");
RegExp hexColorRegex = RegExp(r"^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$");

/// notify bot owner
Future<void> notifyAdministrator(
  String message, {
  String? title,
  DiscordColor? color,
}) async {
  try {
    IUser owner = await client.bot.fetchUser(Snowflake(client.config.ownerId));

    await owner.sendMessage(
      MessageBuilder.embed(
        EmbedBuilder()
          ..title = title ?? "Fishstick Event"
          ..color = color ?? DiscordColor.blue
          ..timestamp = DateTime.now()
          ..footer = (EmbedFooterBuilder()
            ..text = client.footerText
            ..iconUrl = client.bot.self.avatarURL(format: "png"))
          ..description = message,
      ),
    );
  } catch (e) {
    client.logger.shout(
        "An exception occured while notifying bot owner: ${e.toString()}");
  }
}

/// notify premium grant event
Future<void> notifyGrantPremiumEvent({
  required IUser user,
  required IUser partner,
  required Duration duration,
}) async {
  return await notifyAdministrator(
      "Partner ${partner.tag} has granted ${user.tag} premium status for ${duration.inDays} day(s).\n```\nPartner ID: ${partner.id}\nUser ID: ${user.id}\nOperation: Grant Premium Subscription for ${duration.inDays} day(s).\n```");
}

/// notify premium revoke event
Future<void> notifyRevokePremiumEvent({
  required IUser user,
  required IUser partner,
}) async {
  return await notifyAdministrator(
      "Partner ${partner.tag} has revoked ${user.tag} premium status.\n```\nPartner ID: ${partner.id}\nUser ID: ${user.id}\nOperation: Revoke Premium Subscription.\n```");
}

/// notify error event
Future<void> notifyErrorEvent({
  required String source,
  required String error,
}) async {
  return await notifyAdministrator(
    "```\nSource: $source\nError: $error\n```",
    title: "An error occurred!",
    color: DiscordColor.red,
  );
}

/// check if user is premium
Check premiumCheck =
    Check((ctx) async => (await ctx.dbUser).isPremium, "premium-check");

/// check if user is partner
Check partnerCheck =
    Check((ctx) async => (await ctx.dbUser).isPartner, "partner-check");

/// check if user is owner of bot
Check ownerCheck = Check(
    (ctx) async => ctx.user.id.toString() == client.config.ownerId,
    "owner-check");

/// check if command is done in guild
Check guildCheck = Check((ctx) async => ctx.guild != null, "guild-check");

/// override respond function
Future<IMessage> respond(
  IContext ctx,
  MessageBuilder builder, {
  bool hidden = false,
}) async {
  if (ctx is InteractionChatContext) {
    return await ctx.respond(builder, hidden: hidden);
  } else {
    return await ctx.respond(builder);
  }
}

/// get dart version
String get dartVersion {
  final platformVersion = Platform.version;
  return platformVersion.split("(").first;
}

/// get memory usage
String getMemoryUsageString() {
  final current = (ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2);
  final rss = (ProcessInfo.maxRss / 1024 / 1024).toStringAsFixed(2);
  return "$current/${rss}MB";
}

/// encrypt a string
String encrypt(String text) =>
    Encrypter(Salsa20(Key.fromUtf8(client.config.encryptionKey)))
        .encrypt(text, iv: IV.fromLength(8))
        .base64;

/// decrypt a string
String decrypt(String text) =>
    Encrypter(Salsa20(Key.fromUtf8(client.config.encryptionKey)))
        .decrypt64(text, iv: IV.fromLength(8));

/// rarities priority
Map<String, int> raritiesPriority = {
  "common": 1,
  "uncommon": 2,
  "rare": 3,
  "epic": 4,
  "legendary": 5,
  "gaminglegends": 6,
  "shadow": 7,
  "icon": 8,
  "starwars": 9,
  "lava": 10,
  "slurp": 11,
  "dc": 12,
  "marvel": 13,
  "dark": 14,
  "frozen": 15,
  "mythic": 16,
  "crew": 17,
  "exclusive": 18,
};

/// select menu builder for locker options
MultiselectBuilder lockerOptionsBuilder(menuID, AthenaProfile athena) =>
    MultiselectBuilder(
      menuID,
      [
        MultiselectOptionBuilder("Outfits (${athena.skins.length})", "outfits"),
        MultiselectOptionBuilder(
            "Backblings (${athena.backpacks.length})", "backblings"),
        MultiselectOptionBuilder(
            "Pickaxes (${athena.pickaxes.length})", "pickaxes"),
        MultiselectOptionBuilder(
            "Gliders (${athena.gliders.length})", "gliders"),
        MultiselectOptionBuilder(
            "Contrails (${athena.skydiveContrails.length})", "contrails"),
        MultiselectOptionBuilder(
            "Emotes (${athena.dances.where((d) => d.templateId.startsWith("AthenaDance:eid_")).length})",
            "emotes"),
        MultiselectOptionBuilder(
            "Toys (${athena.dances.where((d) => d.templateId.startsWith("AthenaDance:toy_")).length})",
            "toys"),
        MultiselectOptionBuilder(
            "Sprays (${athena.dances.where((d) => d.templateId.startsWith("AthenaDance:spid_")).length})",
            "sprays"),
        MultiselectOptionBuilder("Wraps (${athena.itemWraps.length})", "wraps"),
        MultiselectOptionBuilder(
            "Music Packs (${athena.musicPacks.length})", "music packs"),
        MultiselectOptionBuilder(
            "Loading Screens (${athena.loadingScreens.length})",
            "loading screens"),
      ],
    );

/// filter and sort locker items
List<AthenaCosmetic> filterAndSortCosmetics({
  required DatabaseUser dbUser,
  required String type,
}) {
  List<AthenaCosmetic> cosmetics = [];

  switch (type) {
    case "outfits":
      cosmetics = dbUser.fnClient.athena.skins;
      break;

    case "backblings":
      cosmetics = dbUser.fnClient.athena.backpacks;
      break;

    case "pickaxes":
      cosmetics = dbUser.fnClient.athena.pickaxes;
      break;

    case "gliders":
      cosmetics = dbUser.fnClient.athena.gliders;
      break;

    case "contrails":
      cosmetics = dbUser.fnClient.athena.skydiveContrails;
      break;

    case "emotes":
      cosmetics = dbUser.fnClient.athena.dances
          .where((d) => d.templateId.startsWith("AthenaDance:eid_"))
          .toList();
      break;

    case "toys":
      cosmetics = dbUser.fnClient.athena.dances
          .where((d) => d.templateId.startsWith("AthenaDance:toy_"))
          .toList();
      break;

    case "sprays":
      cosmetics = dbUser.fnClient.athena.dances
          .where((d) => d.templateId.startsWith("AthenaDance:spid_"))
          .toList();
      break;

    case "wraps":
      cosmetics = dbUser.fnClient.athena.itemWraps;
      break;

    case "music packs":
      cosmetics = dbUser.fnClient.athena.musicPacks;
      break;

    case "loading screens":
      cosmetics = dbUser.fnClient.athena.loadingScreens;
      break;

    case "exclusives":
      cosmetics =
          dbUser.fnClient.athena.cosmetics.where((c) => c.isExclusive).toList();
      break;

    case "crew":
      cosmetics =
          dbUser.fnClient.athena.cosmetics.where((c) => c.isCrew).toList();
      break;

    case "exclusives and crew":
      cosmetics = dbUser.fnClient.athena.cosmetics
          .where((c) => c.isExclusive || c.isCrew)
          .toList();
      break;

    case "all":
      cosmetics = dbUser.fnClient.athena.cosmetics;
      break;

    default:
      cosmetics = dbUser.fnClient.athena.cosmetics;
      break;
  }

  cosmetics.sort((a, b) {
    String aRarity = a.isExclusive ? "exclusive" : a.rarity.toLowerCase();
    String bRarity = b.isExclusive ? "exclusive" : b.rarity.toLowerCase();
    if (a.isCrew) {
      aRarity = "crew";
    }
    if (b.isCrew) {
      bRarity = "crew";
    }

    int aPriority = raritiesPriority[aRarity] ?? 0;
    int bPriority = raritiesPriority[bRarity] ?? 0;

    if (bPriority - aPriority == 0) {
      return a.name.compareTo(b.name);
    }

    return bPriority - aPriority;
  });

  return cosmetics;
}

/// draw fortnite locker
Future<List<int>> drawLocker({
  required List<AthenaCosmetic> cosmetics,
  required String epicname,
  required String username,
  bool png = false,
}) async {
  var img = await Dio().post(
    "https://fishstickbot.com/api/locker",
    data: {
      "items": cosmetics
          .map((cosmetic) => {
                "id": cosmetic.templateId,
                "name": cosmetic.name,
                "type": cosmetic.type,
                "rarity": cosmetic.rarity,
                "image": cosmetic.image,
                "isExclusive": cosmetic.isExclusive,
                "isCrew": cosmetic.isCrew,
              })
          .toList(),
      "epicname": epicname,
      "username": username,
      "png": png,
    },
    options: Options(
      responseType: ResponseType.bytes,
      headers: {
        "Authorization": client.config.apiKey,
      },
    ),
  );

  return img.data as List<int>;
}

/// draw fortnite stw resources
Future<List<int>> drawSTWResources({
  required List<Map<String, dynamic>> resources,
  required String epicname,
  required String username,
}) async {
  var img = await Dio().post(
    "https://fishstickbot.com/api/resources",
    data: {
      "items": resources,
      "epicname": epicname,
      "username": username,
    },
    options: Options(
      responseType: ResponseType.bytes,
      headers: {
        "Authorization": client.config.apiKey,
      },
    ),
  );

  return img.data as List<int>;
}

/// draw fortnite stw inventory
Future<List<int>> drawSTWInventory({
  required List<Map<String, dynamic>> items,
  required String epicname,
  required String username,
  bool raw = false,
}) async {
  if (items.isEmpty) {
    throw Exception("No items found.");
  }

  var img = await Dio().post(
    "https://fishstickbot.com/api/inventory",
    data: {
      "items": items,
      "epicname": epicname,
      "username": username,
      "raw": raw,
    },
    options: Options(
      responseType: ResponseType.bytes,
      headers: {
        "Authorization": client.config.apiKey,
      },
    ),
  );

  return img.data as List<int>;
}

/// Purchase an item from fortnite shop
Future<dynamic> purchaseCatalogEntry(
  String offerId, {
  required Client client,
  int quantity = 1,
  String currency = "MtxCurrency",
  String currencySubType = "",
  int expectedTotalPrice = 0,
  String gameContext = "",
}) async {
  return (await client.post(
    MCP(FortniteProfile.common_core, accountId: client.accountId)
        .PurchaseCatalogEntry,
    body: {
      "offerId": offerId,
      "purchaseQuantity": quantity,
      "currency": currency,
      "currencySubType": currencySubType,
      "expectedTotalPrice": expectedTotalPrice,
      "gameContext": gameContext,
    },
  ))?["notifications"]?[0];
}

/// Gift an item from fortnite shop
Future<dynamic> giftCatalogEntry(
  String offerId,
  List<String> receivers, {
  required Client client,
  int quantity = 1,
  String currency = "MtxCurrency",
  String currencySubType = "",
  int expectedTotalPrice = 0,
  String gameContext = "",
  String? message,
}) async {
  return (await client.post(
    "https://fortnite-public-service-prod11.ol.epicgames.com/fortnite/api/game/v2/profile/${client.accountId}/client/GiftCatalogEntry?profileId=common_core",
    body: {
      "offerId": offerId,
      "purchaseQuantity": quantity,
      "currency": currency,
      "currencySubType": currencySubType,
      "expectedTotalPrice": expectedTotalPrice,
      "gameContext": gameContext,
      "receiverAccountIds": receivers,
      "giftWrapTemplateId": "GiftBox:gb_giftwrap4",
      "personalMessage": message != null
          ? "$message\nGifted Using Fishstick Bot! https://fishstickbot.com/"
          : "Gifted Using Fishstick Bot! https://fishstickbot.com/",
    },
  ))?["notifications"]?[0];
}

Future<bool> isEAC(Client fn) async {
  final String launcherToken = await (fn.auth.createOAuthToken(
    grantType: "exchange_code",
    grantData: "exchange_code=${await fn.auth.createExchangeCode()}",
    authClient: AuthClients().launcherAppClient2,
    tokenType: "bearer",
  ));
  final String xc = (await fn.get(
    Endpoints().oauthExchange,
    overrideToken: launcherToken,
  ))["code"];
  var res = await fn.send(
    method: "POST",
    url: Endpoints().calderaToken,
    body: {
      "account_id": fn.accountId,
      "exchange_code": xc,
      "test_mode": false,
      "epic_app": "fortnite",
      "nvidia": false,
    },
  );
  return res["provider"] == "EasyAntiCheat";
}
