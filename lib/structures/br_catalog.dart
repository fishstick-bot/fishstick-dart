import "catalog_item.dart";

class BRCatalog {
  DateTime date;
  String uid;
  final List<dynamic> _items;
  List<CatalogItem> items = [];

  BRCatalog(
    this._items, {
    required this.date,
    required this.uid,
  }) {
    for (final i in _items) {
      items.add(
        CatalogItem(
          offerId: i["offerId"],
          id: i["mainId"].toString().toLowerCase(),
          name: i["displayName"],
          description: i["displayDescription"],
          canBuy: i["buyAllowed"],
          canGift: i["giftAllowed"],
          currency: "MtxCurrency",
          regularPrice: i["price"]["regularPrice"],
          finalPrice: i["price"]["finalPrice"],
          rarity: i["rarity"]["name"].toString().toLowerCase(),
        ),
      );
    }
  }

  @override
  String toString() => "BRCatalog $uid";
}
