import "package:async/async.dart";
import "package:nyxx/nyxx.dart" hide ClientOptions;
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:random_string/random_string.dart";
import "package:fortnite/fortnite.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../utils/utils.dart";
import "../../../../fishstick_dart.dart";

final ChatCommand loginSwitchCommand = ChatCommand(
  "switch",
  "Switch current active account.",
  Id(
    "login_switch_command",
    (IContext ctx) async {
      final DatabaseUser user = await ctx.dbUser;

      final String newAccountButtonID = "${randomString(30)}-new";
      final String cancelButtonID = "${randomString(30)}-cancel";
      final String accountMenuID = "${randomString(30)}-accountmenu";

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

      final ButtonBuilder newAccountButton = ButtonBuilder(
        "NEW",
        newAccountButtonID,
        ButtonStyle.success,
        disabled: user.linkedAccounts.length >= user.accountsLimit,
      );

      final ButtonBuilder cancelButton = ButtonBuilder(
        "CANCEL",
        cancelButtonID,
        ButtonStyle.danger,
      );

      final ComponentRowBuilder buttonsRow = ComponentRowBuilder()
        ..addComponent(newAccountButton)
        ..addComponent(cancelButton);

      if (user.linkedAccounts.isEmpty) {
        await respond(
          ctx,
          ComponentMessageBuilder()
            ..embeds = [
              authorizationCodeEmbed
                ..color = DiscordColor.fromHexString(user.color)
                ..description =
                    "Click **Authorization Code** button to get an authorization code then do command `/login code` to login to your Epic account.",
            ]
            ..addComponentRow(authorizationCodeRow),
        );
        return;
      }

      final ComponentRowBuilder accountMenuRow = ComponentRowBuilder();

      int index = 0;
      for (final accs in await user.linkedAccounts.chunk(25).toList()) {
        final MultiselectBuilder accountMenu = MultiselectBuilder(
          "$accountMenuID-$index",
          accs.map((a) => MultiselectOptionBuilder(
                a.displayName,
                a.accountId,
                user.selectedAccount == a.accountId,
              )),
        );
        accountMenuRow.addComponent(accountMenu);

        index++;
      }

      final EmbedBuilder loginEmbed = EmbedBuilder()
        ..author = (EmbedAuthorBuilder()
          ..name = ctx.user.username
          ..iconUrl = ctx.user.avatarURL(format: "png"))
        ..color = DiscordColor.fromHexString(user.color)
        ..description =
            "To switch to a different account use the drop down menu below.\nTo login to a new account, click the **NEW** button below.\nThis message will timeout in 60 Seconds."
        ..footer = (EmbedFooterBuilder()..text = client.footerText)
        ..timestamp = DateTime.now();

      IMessage msg = await respond(
        ctx,
        ComponentMessageBuilder()
          ..embeds = [loginEmbed]
          ..addComponentRow(accountMenuRow)
          ..addComponentRow(buttonsRow),
      );

      var selected = await (StreamGroup()
            ..add(ctx.commands.interactions.events.onButtonEvent.where(
                (event) => ([newAccountButtonID, cancelButtonID]
                        .contains(event.interaction.customId) &&
                    event.interaction.userAuthor?.id == ctx.user.id)))
            ..add(ctx.commands.interactions.events.onMultiselectEvent.where(
                (event) =>
                    (event.interaction.customId.contains(accountMenuID) &&
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
      } else if ((selected.interaction?.customId ?? "")
          .toString()
          .contains("new")) {
        await msg.edit(
          ComponentMessageBuilder()
            ..embeds = [
              authorizationCodeEmbed
                ..color = DiscordColor.fromHexString(user.color)
                ..description =
                    "Click **Authorization Code** button to get an authorization code then do command `/login code` to login to your Epic account.",
            ]
            ..componentRows = []
            ..addComponentRow(authorizationCodeRow),
        );
        return;
      } else {
        List<String> selections = selected?.interaction?.values as List<String>;
        await user.setActiveAccount(selections.first);

        await msg.edit(
          ComponentMessageBuilder()
            ..embeds = [
              EmbedBuilder()
                ..author = (EmbedAuthorBuilder()
                  ..name = ctx.user.username
                  ..iconUrl = ctx.user.avatarURL(format: "png"))
                ..color = DiscordColor.fromHexString(user.color)
                ..title = "Successfully switched active account!"
                ..thumbnailUrl = user.activeAccount.avatar
                ..description =
                    "Switched to account **${user.activeAccount.displayName}**."
                ..addField(
                  name: "Account ID",
                  content: user.activeAccount.accountId,
                  inline: true,
                )
                ..timestamp = DateTime.now()
                ..footer = (EmbedFooterBuilder()..text = client.footerText),
            ]
            ..componentRows = [],
        );
        return;
      }
    },
  ),
);
