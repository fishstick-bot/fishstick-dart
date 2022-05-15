import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../fishstick_dart.dart";

final ChatCommand brShopCommand = ChatCommand(
  "br",
  "View fortnite battle royale item shop.",
  id(
    "br_shop_command",
    (IContext ctx) async {
      await ctx.respond(MessageBuilder.content(
          "https://fishstickbot.com/api/shop.png?v=${client.systemJobs.catalogManagerSystemJob.brCatalog.uid}"));
    },
  ),
);
