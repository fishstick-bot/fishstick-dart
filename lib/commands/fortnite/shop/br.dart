import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

final ChatCommand brShopCommand = ChatCommand(
  "shop",
  "View fortnite battle royale item shop.",
  Id(
    "br_shop_command",
    (IContext ctx) async {
      await ctx.respond(MessageBuilder.content(
          "https://fishstickbot.com/api/shop.png?v=${DateTime.now().millisecondsSinceEpoch}"));
    },
  ),
);
