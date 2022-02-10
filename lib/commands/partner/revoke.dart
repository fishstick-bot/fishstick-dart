import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_user.dart";
import "../../fishstick_dart.dart";
import "../../utils/utils.dart";

final ChatCommand revokePartnerCommand = ChatCommand(
  "revoke",
  "Revoke a user's partner tier.",
  Id(
    "revoke_partner_command",
    (
      IContext ctx,
      @Description("The user you want to revoke partner tier of.") IUser user,
    ) async {
      // DatabaseUser dbUser = await ctx.dbUser;
      DatabaseUser targetUser =
          await client.database.getUser(user.id.toString());

      if (!targetUser.isPartner) {
        return await respond(
          ctx,
          MessageBuilder.content(
              "This user is not a partner, so you cannot revoke their partner tier."),
          hidden: true,
        );
      }

      await targetUser.updatePartnerStatus(ctx.user, user, false);

      return await respond(
        ctx,
        MessageBuilder.content(
            "You have revoked ${user.mention}'s partner tier."),
      );
    },
  ),
  checks: [ownerCheck],
);
