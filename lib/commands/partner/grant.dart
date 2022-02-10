import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_user.dart";
import "../../fishstick_dart.dart";
import "../../utils/utils.dart";

final ChatCommand grantPartnerCommand = ChatCommand(
  "grant",
  "Grant a user a partner tier.",
  Id(
    "grant_partner_command",
    (
      IContext ctx,
      @Description("The user you want to grant partner.") IUser user,
    ) async {
      // DatabaseUser dbUser = await ctx.dbUser;
      DatabaseUser targetUser =
          await client.database.getUser(user.id.toString());

      if (targetUser.isPartner) {
        return await respond(
          ctx,
          MessageBuilder.content("This user is already a partner."),
          hidden: true,
        );
      }

      await targetUser.updatePartnerStatus(ctx.user, user, true);

      return await respond(
        ctx,
        MessageBuilder.content(
            "You have granted ${user.mention}'s partner tier."),
      );
    },
  ),
  checks: [ownerCheck],
);
