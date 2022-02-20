// ignore_for_file: avoid_print

import "package:mongo_dart/mongo_dart.dart";
import "package:fishstick_dart/fishstick_dart.dart";
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

    if (exclusives.contains(c["id"].toString().toLowerCase())) {
      c["isExclusive"] = true;
      await client.database.cosmetics
          .updateOne(where.eq("id", c["id"]), modify.set("isExclusive", true));
    } else {
      c["isExclusive"] = false;
      await client.database.cosmetics
          .updateOne(where.eq("id", c["id"]), modify.set("isExclusive", false));
    }

    if (crew.contains(c["id"].toString().toLowerCase())) {
      c["isCrew"] = true;
      await client.database.cosmetics
          .updateOne(where.eq("id", c["id"]), modify.set("isCrew", true));
    } else {
      c["isCrew"] = false;
      await client.database.cosmetics
          .updateOne(where.eq("id", c["id"]), modify.set("isCrew", false));
    }

    print("[$i/${cache.length}] ${c["id"]}");
  }

  await db.close();
}
