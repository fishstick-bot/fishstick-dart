// ignore_for_file: avoid_print

import "package:mongo_dart/mongo_dart.dart";
import "package:fishstick_dart/config.dart";
import "package:fishstick_dart/resources/exclusives.dart";
import "package:fishstick_dart/resources/crew.dart";

void main() async {
  final Db db = Db(Config().mongoUri);
  await db.open();

  final DbCollection cosmetics = db.collection("cosmetics");
  final cache = await cosmetics.find().toList();

  int i = 0;
  for (final c in cache) {
    i++;

    if (c["isExclusive"] == null) {
      await cosmetics.updateOne(
          where.eq("id", c["id"]), modify.set("isExclusive", false));
    }
    if (c["isCrew"] == null) {
      await cosmetics.updateOne(
          where.eq("id", c["id"]), modify.set("isCrew", false));
    }

    if (exclusives.contains(c["id"].toString().toLowerCase()) &&
        c["isExclusive"] == false) {
      c["isExclusive"] = true;
      await cosmetics.updateOne(
          where.eq("id", c["id"]), modify.set("isExclusive", true));
    }

    if (c["isExclusive"] == true &&
        !exclusives.contains(c["id"].toString().toLowerCase())) {
      c["isExclusive"] = false;
      await cosmetics.updateOne(
          where.eq("id", c["id"]), modify.set("isExclusive", false));
    }

    if (crew.contains(c["id"].toString().toLowerCase()) &&
        c["isCrew"] == false) {
      c["isCrew"] = true;
      await cosmetics.updateOne(
          where.eq("id", c["id"]), modify.set("isCrew", true));
    }

    if (c["isCrew"] == true &&
        !crew.contains(c["id"].toString().toLowerCase())) {
      c["isCrew"] = false;
      await cosmetics.updateOne(
          where.eq("id", c["id"]), modify.set("isCrew", false));
    }

    print("[$i/${cache.length}] ${c["id"]}");
  }

  await db.close();
}
