class CatalogItem {
  String offerId;
  String id;
  String name;
  String description;
  bool canBuy;
  bool canGift;
  String currency;
  String subCurrency;
  int regularPrice;
  int finalPrice;
  String rarity;

  CatalogItem({
    required this.offerId,
    required this.id,
    required this.name,
    required this.description,
    required this.canBuy,
    required this.canGift,
    required this.currency,
    this.subCurrency = "",
    required this.regularPrice,
    required this.finalPrice,
    required this.rarity,
  });

  @override
  String toString() => "CatalogItem $name - $finalPrice $currency";
}
