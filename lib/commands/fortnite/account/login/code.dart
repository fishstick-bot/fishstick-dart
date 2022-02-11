import "package:nyxx/nyxx.dart" hide ClientOptions;
import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "package:fortnite/fortnite.dart";
import "../../../../structures/epic_account.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../../fishstick_dart.dart";

final ChatCommand loginCodeCommand = ChatCommand(
  "code",
  "Login to a new epic account.",
  Id(
    "login_code_command",
    (IContext ctx) async {
      final DatabaseUser user = await ctx.dbUser;

      final TextInputBuilder textInput = TextInputBuilder(
        "${ctx.user.id.toString()}-authcode",
        TextInputStyle.short,
        "Enter your authorization code.",
      )
        ..minLength = 32
        ..required = true
        ..placeholder = "11223344556677889900AABBCCDDEEFF";

      if (ctx is! InteractionChatContext) {
        throw Exception("This command can only be used as a slash command.");
      }

      await ctx.interactionEvent.respondModal(
        ModalBuilder("${ctx.user.id}-login-new", "Login to Epic")
          ..componentRows = [
            ComponentRowBuilder()..addComponent(textInput),
          ],
      );

      try {
        var selected = await ctx.commands.interactions.events.onModalEvent
            .firstWhere(
                (e) => e.interaction.customId == "${ctx.user.id}-login-new")
            .timeout(Duration(minutes: 2));

        await selected.acknowledge(hidden: true).catchError((_) => null);

        try {
          final String code =
              (selected.interaction.components.first.first as IMessageTextInput)
                  .value;

          if (user.linkedAccounts.length >= user.accountsLimit) {
            throw Exception(
                "You have reached the limit of linked epic accounts.");
          }

          final DeviceAuth deviceAuth =
              await authenticateWithAuthorizationCode(code);

          if (user.linkedAccounts
              .where((a) => a.accountId == deviceAuth.accountId)
              .isNotEmpty) {
            throw Exception("You already linked this account.");
          }

          final Client fn = Client(
            options: ClientOptions(
              deviceAuth: deviceAuth,
              logLevel: Level.INFO,
            ),
          )..onSessionUpdate.listen((Client update) {
              user.sessions[update.accountId] = update.session;
            });

          final EpicAccount account = EpicAccount.fromJson({
            "accountId": deviceAuth.accountId,
            "deviceId": client.encryptString(deviceAuth.deviceId),
            "secret": client.encryptString(deviceAuth.secret),
            "displayName": deviceAuth.displayName,
            "avatar": (await fn.getAvatars([fn.accountId])).first.icon,
            "cachedResearchValues": {
              "fortitude": 0,
              "resistance": 0,
              "offense": 0,
              "tech": 0,
            },
            "dailiesLastRefresh": 0,
            "lastDailyRewardClaim": 0,
            "lastFreeLlamasClaim": 0,
            "powerLevel": 0,
            "savedHeroLoadouts": [],
            "savedSurvivorSquads": [],
          });

          await user.addAccount(account);

          await selected.editOriginalResponse(
            MessageBuilder.embed(
              EmbedBuilder()
                ..author = (EmbedAuthorBuilder()
                  ..name = ctx.user.username
                  ..iconUrl = ctx.user.avatarURL(format: "png"))
                ..color = DiscordColor.fromHexString(user.color)
                ..title = "👋 Welcome, ${account.displayName}"
                ..thumbnailUrl = account.avatar
                ..description =
                    "Your epic account has been successfully linked to your discord account."
                ..addField(
                  name: "Account ID",
                  content: account.accountId,
                  inline: true,
                )
                ..timestamp = DateTime.now()
                ..footer = (EmbedFooterBuilder()..text = client.footerText),
            ),
          );
        } catch (e) {
          await selected.editOriginalResponse(
            MessageBuilder.content(
              "<@${ctx.user.id}>, An error occurred while trying to link your account.\n$e",
            ),
          );
        }
      } catch (e) {
        await ctx.channel.sendMessage(
          MessageBuilder.content(
            "<@${ctx.user.id}>, An error occurred while trying to link your account.\n$e",
          ),
        );
      }
    },
  ),
  options: CommandOptions(
    hideOriginalResponse: true,
  ),
);
