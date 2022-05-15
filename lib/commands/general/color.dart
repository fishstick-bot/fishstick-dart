import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_user.dart";
import "../../extensions/context_extensions.dart";
import "../../utils/utils.dart";
import "../../fishstick_dart.dart";

final ChatCommand colorCommand = ChatCommand(
  "color",
  "Configure color to be used for embeds etc.",
  id(
    "color_command",
    (
      IContext ctx,
      @Description("Hex color code to use for the color.") String hexcode,
    ) async {
      DatabaseUser user = await ctx.dbUser;

      if (!hexColorRegex.hasMatch(hexcode)) {
        throw Exception("Invalid hex color code.");
      }

      user.color = hexcode;

      await client.database.updateUser(user.id, {
        "color": user.color,
      });

      await respond(
        ctx,
        MessageBuilder.embed(EmbedBuilder()
          ..description = "Color set to ${user.color}."
          ..timestamp = DateTime.now()
          ..footer = (EmbedFooterBuilder()..text = client.footerText)
          ..imageUrl =
              "https://singlecolorimage.com/get/${user.color.replaceAll("#", "")}/500x500"),
      );
    },
  ),
  checks: [premiumCheck],
);
