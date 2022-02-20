// ignore_for_file: avoid_print

import "package:mongo_dart/mongo_dart.dart";
import "package:fishstick_dart/config.dart";
import "package:fishstick_dart/resources/exclusives.dart";
import "package:fishstick_dart/resources/crew.dart";

void main() async {
  final Db db = Db(Config().mongoUri);
  await db.open();

  final DbCollection cosmetics = db.collection("cosmetics");
  var cache = await cosmetics.find().toList();

  for (final c in cache) {
    String id = c["id"];

    if (exclusives.contains(id) && c["isExclusive"] == false) {
      print("Adding $id to exclusives");
      await cosmetics.updateOne(
          where.eq("id", id), modify.set("isExclusive", true));
    }

    if (crew.contains(id) && c["isCrew"] == false) {
      print("Adding $id to crew");
      await cosmetics.updateOne(where.eq("id", id), modify.set("isCrew", true));
    }
  }

  await db.close();
}
