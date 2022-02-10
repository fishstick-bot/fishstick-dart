import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../fishstick_dart.dart";

final ChatCommand externalViewCommand = ChatCommand(
  "view",
  "View your account external auth connections information.",
  (IContext ctx) async {
    DatabaseUser user = await ctx.dbUser;
    user.fnClientSetup();

    final externalAuths = await user.fnClient.auth.getExternalAuths();
    if (externalAuths.isEmpty) {
      throw Exception("You don't have any external auths.");
    }

    var externalAuthNames = {
      "google": "Google",
      "github": "GitHub",
      "psn": "PlayStation Network",
      "xbl": "Xbox Live",
    };

    return await ctx.respond(
      MessageBuilder.embed(
        EmbedBuilder()
          ..author = (EmbedAuthorBuilder()
            ..name = ctx.user.username
            ..iconUrl = ctx.user.avatarURL(format: "png"))
          ..color = DiscordColor.fromHexString(user.color)
          ..footer = (EmbedFooterBuilder()..text = client.footerText)
          ..timestamp = DateTime.now()
          ..title = "${user.activeAccount.displayName} | External Auths"
          ..thumbnailUrl = user.activeAccount.avatar
          ..description =
              "${externalAuths.map((e) => "• ${externalAuthNames[e.type] ?? e.type.toUpperCase()}: **${e.externalDisplayName}**").join("\n")}\n\nYou can unlink an external auth with:\n• /account external unlink <platform>",
      ),
      private: true,
    );
  },
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
  checks: [],
);
