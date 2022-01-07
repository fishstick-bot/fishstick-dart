import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_user.dart";
import "../../fishstick_dart.dart";
import "../../utils/utils.dart";

final Command premiumRevokeCommand = Command(
  "revoke",
  "Revoke a user's premium subscription.",
  (
    Context ctx,
    @Description("The user you want to revoke premium subscription of.")
        IUser user,
  ) async {
    // DatabaseUser dbUser = await ctx.dbUser;
    DatabaseUser targetUser = await client.database.getUser(user.id.toString());

    if (targetUser.isPartner) {
      return await respond(
        ctx,
        MessageBuilder.content(
            "This user is a partner. You cannot revoke their subscription."),
        hidden: true,
      );
    }

    if (!targetUser.isPremium) {
      return await respond(
        ctx,
        MessageBuilder.content(
            "This user dont have an active premium subscription."),
        hidden: true,
      );
    }

    await targetUser.revokePremium(ctx.user, user);

    return await respond(
      ctx,
      MessageBuilder.content(
          "You have revoked ${user.mention}'s premium subscription."),
    );
  },
  checks: [
    partnerCheck,
  ],
);
