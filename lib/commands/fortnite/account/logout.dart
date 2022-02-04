import "package:async/async.dart";
import "package:nyxx/nyxx.dart" hide ClientOptions;
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:random_string/random_string.dart";
import "../../../structures/epic_account.dart";
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";
import "../../../utils/utils.dart";
import "../../../fishstick_dart.dart";

final Command logoutCommand = Command(
  "logout",
  "Logout of your saved epic accounts.",
  (Context ctx) async {
    final DatabaseUser user = await ctx.dbUser;

    if (user.linkedAccounts.isEmpty) {
      throw Exception("You don't have any linked epic accounts.");
    }

    final String cancelButtonID = "${randomString(30)}-cancel";
    final String accountMenuID = "${randomString(30)}-accountmenu";

    final ButtonBuilder cancelButton = ButtonBuilder(
      "CANCEL",
      cancelButtonID,
      ComponentStyle.danger,
    );

    final ComponentRowBuilder buttonsRow = ComponentRowBuilder()
      ..addComponent(cancelButton);

    final MultiselectBuilder accountMenu = MultiselectBuilder(
      accountMenuID,
      user.linkedAccounts.map((a) => MultiselectOptionBuilder(
            a.displayName,
            a.accountId,
          )),
    );

    final EmbedBuilder loginEmbed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(user.color)
      ..description =
          "To logout from an account use the drop down menu below.\nThis message will timeout in 60 Seconds."
      ..footer = (EmbedFooterBuilder()..text = client.footerText)
      ..timestamp = DateTime.now();

    IMessage msg = await respond(
      ctx,
      ComponentMessageBuilder()
        ..embeds = [loginEmbed]
        ..addComponentRow(ComponentRowBuilder()..addComponent(accountMenu))
        ..addComponentRow(buttonsRow),
    );

    try {
      var selected = await (StreamGroup()
            ..add(ctx.commands.interactions.events.onButtonEvent.where(
                (event) =>
                    ([cancelButtonID].contains(event.interaction.customId) &&
                        event.interaction.userAuthor?.id == ctx.user.id)))
            ..add(ctx.commands.interactions.events.onMultiselectEvent.where(
                (event) =>
                    ([accountMenuID].contains(event.interaction.customId) &&
                        event.interaction.userAuthor?.id == ctx.user.id))))
          .stream
          .timeout(Duration(minutes: 1))
          .first;

      await selected?.acknowledge();

      if ((selected.interaction?.customId ?? "")
          .toString()
          .contains("cancel")) {
        await msg.delete();
        return;
      } else {
        List<String> selections = selected?.interaction?.values as List<String>;
        final EpicAccount logoutAcc = user.linkedAccounts
            .firstWhere((a) => a.accountId == selections.first);
        await user.removeAccount(logoutAcc);

        await msg.edit(
          ComponentMessageBuilder()
            ..embeds = [
              EmbedBuilder()
                ..author = (EmbedAuthorBuilder()
                  ..name = ctx.user.username
                  ..iconUrl = ctx.user.avatarURL(format: "png"))
                ..color = DiscordColor.fromHexString(user.color)
                ..title = "Successfully logged out!"
                ..thumbnailUrl = logoutAcc.avatar
                ..description = "Logged out of **${logoutAcc.displayName}**."
                ..addField(
                  name: "Account ID",
                  content: logoutAcc.accountId,
                  inline: true,
                )
                ..timestamp = DateTime.now()
                ..footer = (EmbedFooterBuilder()..text = client.footerText),
            ]
            ..componentRows = [],
        );
        return;
      }
    } catch (e) {
      await msg.delete();
      return;
    }
  },
  aliases: ["o"],
  checks: [],
);
