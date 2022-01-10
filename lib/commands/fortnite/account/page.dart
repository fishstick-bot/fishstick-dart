import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
// import "package:fortnite/fortnite.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";
import "../../../utils/utils.dart";

final Command accountSettingsPageCommand = Command(
  "page",
  "Create a link to visit your epic games account settings.",
  (Context ctx) async {
    DatabaseUser user = await ctx.dbUser;
    user.fnClientSetup();

    return await ctx.respond(
      ComponentMessageBuilder()
        ..content =
            "Visit your Epic Games account settings by clicking on the button below."
        ..addComponentRow(
          ComponentRowBuilder()
            ..addComponent(
              LinkButtonBuilder(
                "Account Page",
                "https://epicgames.com/id/exchange?exchangeCode=${await (user.fnClient.auth.createExchangeCode())}",
              ),
            ),
        ),
      private: true,
    );
  },
  hideOriginalResponse: true,
  checks: [premiumCheck],
);
