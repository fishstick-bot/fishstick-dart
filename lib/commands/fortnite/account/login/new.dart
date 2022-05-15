import "package:nyxx/nyxx.dart" hide ClientOptions;
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:fortnite/fortnite.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";

final ChatCommand loginNewCommand = ChatCommand(
  "new",
  "Login to a new epic account.",
  id(
    "login_new_command",
    (IContext ctx) async {
      final DatabaseUser user = await ctx.dbUser;

      final EmbedBuilder authorizationCodeEmbed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(user.color)
        ..footer = (EmbedFooterBuilder()
          ..text =
              "Visit Authorization Code 2 button if you wanna forcefully switch accounts.")
        ..timestamp = DateTime.now();

      final LinkButtonBuilder authorizationCodeButton = LinkButtonBuilder(
        "Authorization Code",
        getAuthorizationCodeURL(),
      );

      final LinkButtonBuilder switchAccountAuthorizationCodeButton =
          LinkButtonBuilder(
        "Authorization Code 2",
        getAuthorizationCodeURL() + "&prompt=login",
      );

      final ComponentRowBuilder authorizationCodeRow = ComponentRowBuilder()
        ..addComponent(authorizationCodeButton)
        ..addComponent(switchAccountAuthorizationCodeButton);

      await ctx.respond(
        ComponentMessageBuilder()
          ..embeds = [
            authorizationCodeEmbed
              ..color = DiscordColor.fromHexString(user.color)
              ..description =
                  "Click **Authorization Code** button to get an authorization code then do command `/login code` to login to your Epic account.",
          ]
          ..addComponentRow(authorizationCodeRow),
      );
    },
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
);
