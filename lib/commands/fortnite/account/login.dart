/// OLD LOGIN COMMAND DEPRECATED NOW
///
// import "package:async/async.dart";
// import "package:nyxx/nyxx.dart" hide ClientOptions;
// import "package:nyxx_commands/nyxx_commands.dart";
// import "package:nyxx_interactions/nyxx_interactions.dart";
// import "package:random_string/random_string.dart";
// import "package:fortnite/fortnite.dart";
// import "../../../structures/epic_account.dart";
// import "../../../database/database_user.dart";
// import "../../../extensions/context_extensions.dart";
// import "../../../utils/utils.dart";
// import "../../../fishstick_dart.dart";

// final ChatCommand loginCommand = ChatCommand(
//   "login",
//   "Switch current active account or Login to a new epic account.",
//   Id(
//     "login_commanc",
//     (IContext ctx) async {
//       final DatabaseUser user = await ctx.dbUser;

//       final String newAccountButtonID = "${randomString(30)}-new";
//       final String cancelButtonID = "${randomString(30)}-cancel";
//       final String accountMenuID = "${randomString(30)}-accountmenu";

//       final EmbedBuilder authorizationCodeEmbed = EmbedBuilder()
//         ..author = (EmbedAuthorBuilder()
//           ..name = ctx.user.username
//           ..iconUrl = ctx.user.avatarURL(format: "png"))
//         ..color = DiscordColor.fromHexString(user.color)
//         ..footer = (EmbedFooterBuilder()
//           ..text =
//               "Visit Authorization Code 2 button if you wanna forcefully switch accounts.")
//         ..timestamp = DateTime.now();

//       final LinkButtonBuilder authorizationCodeButton = LinkButtonBuilder(
//         "Authorization Code",
//         getAuthorizationCodeURL(),
//       );

//       final LinkButtonBuilder switchAccountAuthorizationCodeButton =
//           LinkButtonBuilder(
//         "Authorization Code 2",
//         getAuthorizationCodeURL() + "&prompt=login",
//       );

//       final ComponentRowBuilder authorizationCodeRow = ComponentRowBuilder()
//         ..addComponent(authorizationCodeButton)
//         ..addComponent(switchAccountAuthorizationCodeButton);

//       final ButtonBuilder newAccountButton = ButtonBuilder(
//         "NEW",
//         newAccountButtonID,
//         ButtonStyle.success,
//         disabled: user.linkedAccounts.length >= user.accountsLimit,
//       );

//       final ButtonBuilder cancelButton = ButtonBuilder(
//         "CANCEL",
//         cancelButtonID,
//         ButtonStyle.danger,
//       );

//       final ComponentRowBuilder buttonsRow = ComponentRowBuilder()
//         ..addComponent(newAccountButton)
//         ..addComponent(cancelButton);

//       // if (user.linkedAccounts.isEmpty && code == null) {
//       //   await respond(
//       //     ctx,
//       //     ComponentMessageBuilder()
//       //       ..embeds = [
//       //         authorizationCodeEmbed
//       //           ..color = DiscordColor.fromHexString(user.color)
//       //           ..description =
//       //               "Click **Authorization Code** button to get an authorization code then do command `/login <code>` to login to your Epic account.",
//       //       ]
//       //       ..addComponentRow(authorizationCodeRow),
//       //   );
//       //   return;
//       // }

//       // if (code != null && code.isEmpty) {
//       //   await respond(
//       //     ctx,
//       //     ComponentMessageBuilder()
//       //       ..embeds = [
//       //         authorizationCodeEmbed
//       //           ..color = DiscordColor.red
//       //           ..description =
//       //               "An authorization code is 32 characters long.\nClick **Authorization Code** button to get an authorization code then do command `/login <code>` to login to your Epic account.",
//       //       ]
//       //       ..addComponentRow(authorizationCodeRow),
//       //   );
//       //   return;
//       // }

//       // if (code != null) {
//       //   if (user.linkedAccounts.length >= user.accountsLimit) {
//       //     throw Exception(
//       //         "You have reached the limit of linked epic accounts.");
//       //   }

//       //   final DeviceAuth deviceAuth =
//       //       await authenticateWithAuthorizationCode(code);

//       //   if (user.linkedAccounts
//       //       .where((a) => a.accountId == deviceAuth.accountId)
//       //       .isNotEmpty) {
//       //     throw Exception("You already linked this account.");
//       //   }

//       //   final Client fn = Client(
//       //     options: ClientOptions(
//       //       deviceAuth: deviceAuth,
//       //       logLevel: Level.INFO,
//       //     ),
//       //   )..onSessionUpdate.listen((Client update) {
//       //       user.sessions[update.accountId] = update.session;
//       //     });

//       //   final EpicAccount account = EpicAccount.fromJson({
//       //     "accountId": deviceAuth.accountId,
//       //     "deviceId": client.encryptString(deviceAuth.deviceId),
//       //     "secret": client.encryptString(deviceAuth.secret),
//       //     "displayName": deviceAuth.displayName,
//       //     "avatar": (await fn.getAvatars([fn.accountId])).first.icon,
//       //     "cachedResearchValues": {
//       //       "fortitude": 0,
//       //       "resistance": 0,
//       //       "offense": 0,
//       //       "tech": 0,
//       //     },
//       //     "dailiesLastRefresh": 0,
//       //     "lastDailyRewardClaim": 0,
//       //     "lastFreeLlamasClaim": 0,
//       //     "powerLevel": 0,
//       //     "savedHeroLoadouts": [],
//       //     "savedSurvivorSquads": [],
//       //   });

//       //   await user.addAccount(account);

//       //   await respond(
//       //     ctx,
//       //     ComponentMessageBuilder()
//       //       ..embeds = [
//       //         EmbedBuilder()
//       //           ..author = (EmbedAuthorBuilder()
//       //             ..name = ctx.user.username
//       //             ..iconUrl = ctx.user.avatarURL(format: "png"))
//       //           ..color = DiscordColor.fromHexString(user.color)
//       //           ..title = "👋 Welcome, ${account.displayName}"
//       //           ..thumbnailUrl = account.avatar
//       //           ..description =
//       //               "Your epic account has been successfully linked to your discord account."
//       //           ..addField(
//       //             name: "Account ID",
//       //             content: account.accountId,
//       //             inline: true,
//       //           )
//       //           ..timestamp = DateTime.now()
//       //           ..footer = (EmbedFooterBuilder()..text = client.footerText),
//       //       ],
//       //   );
//       //   return;
//       // }

//       final TextInputBuilder textInput = TextInputBuilder(
//         "${ctx.user.id.toString()}-authcode",
//         TextInputStyle.short,
//         "Enter your authorization code.",
//       )
//         ..minLength = 32
//         ..required = true
//         ..placeholder = "11223344556677889900AABBCCDDEEFF";

//       final MultiselectBuilder accountMenu = MultiselectBuilder(
//         accountMenuID,
//         user.linkedAccounts.map((a) => MultiselectOptionBuilder(
//               a.displayName,
//               a.accountId,
//               user.selectedAccount == a.accountId,
//             )),
//       );

//       final EmbedBuilder loginEmbed = EmbedBuilder()
//         ..author = (EmbedAuthorBuilder()
//           ..name = ctx.user.username
//           ..iconUrl = ctx.user.avatarURL(format: "png"))
//         ..color = DiscordColor.fromHexString(user.color)
//         ..description =
//             "To switch to a different account use the drop down menu below.\nTo login to a new account, click the **NEW** button below.\nThis message will timeout in 60 Seconds."
//         ..footer = (EmbedFooterBuilder()..text = client.footerText)
//         ..timestamp = DateTime.now();

//       IMessage msg = await respond(
//         ctx,
//         ComponentMessageBuilder()
//           ..embeds = [loginEmbed]
//           ..addComponentRow(ComponentRowBuilder()..addComponent(accountMenu))
//           ..addComponentRow(buttonsRow),
//       );

//       var selected = await (StreamGroup()
//             ..add(ctx.commands.interactions.events.onButtonEvent.where(
//                 (event) => ([newAccountButtonID, cancelButtonID]
//                         .contains(event.interaction.customId) &&
//                     event.interaction.userAuthor?.id == ctx.user.id)))
//             ..add(ctx.commands.interactions.events.onMultiselectEvent.where(
//                 (event) =>
//                     ([accountMenuID].contains(event.interaction.customId) &&
//                         event.interaction.userAuthor?.id == ctx.user.id))))
//           .stream
//           .timeout(Duration(minutes: 1))
//           .first;

//       await selected?.acknowledge();

//       if ((selected.interaction?.customId ?? "")
//           .toString()
//           .contains("cancel")) {
//         await msg.delete();
//         return;
//       } else if ((selected.interaction?.customId ?? "")
//           .toString()
//           .contains("new")) {
//         if (ctx is! InteractionChatContext) {
//           throw Exception("This command can only be used as a slash command.");
//         }

//         await ctx.interactionEvent.respondModal(
//           ModalBuilder("${ctx.user.id}-login-new", "Login to Epic")
//             ..componentRows = [
//               ComponentRowBuilder()..addComponent(textInput),
//               buttonsRow
//             ],
//         );

//         // await msg.edit(
//         //   ComponentMessageBuilder()
//         //     ..embeds = [
//         //       authorizationCodeEmbed
//         //         ..color = DiscordColor.fromHexString(user.color)
//         //         ..description =
//         //             "Click **Authorization Code** button to get an authorization code then do command `/login <code>` to login to your Epic account.",
//         //     ]
//         //     ..componentRows = []
//         //     ..addComponentRow(authorizationCodeRow),
//         // );
//         return;
//       } else {
//         List<String> selections = selected?.interaction?.values as List<String>;
//         await user.setActiveAccount(selections.first);

//         await msg.edit(
//           ComponentMessageBuilder()
//             ..embeds = [
//               EmbedBuilder()
//                 ..author = (EmbedAuthorBuilder()
//                   ..name = ctx.user.username
//                   ..iconUrl = ctx.user.avatarURL(format: "png"))
//                 ..color = DiscordColor.fromHexString(user.color)
//                 ..title = "Successfully switched active account!"
//                 ..thumbnailUrl = user.activeAccount.avatar
//                 ..description =
//                     "Switched to account **${user.activeAccount.displayName}**."
//                 ..addField(
//                   name: "Account ID",
//                   content: user.activeAccount.accountId,
//                   inline: true,
//                 )
//                 ..timestamp = DateTime.now()
//                 ..footer = (EmbedFooterBuilder()..text = client.footerText),
//             ]
//             ..componentRows = [],
//         );
//         return;
//       }
//     },
//   ),
//   aliases: ["i"],
//   checks: [],
//   options: CommandOptions(
//     hideOriginalResponse: true,
//   ),
// );
