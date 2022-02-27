import "package:nyxx_commands/nyxx_commands.dart";

import "../../../../utils/utils.dart";

import "use.dart";
import "gift.dart";

final ChatGroup xpBoostCommand = ChatGroup(
  "xpboost",
  "Use/gift STW XP boosts.",
  children: [
    useXpBoostCommand,
    giftXpBoostCommand,
  ],
  checks: [premiumCheck],
);
