import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_user.dart";
import "../../fishstick_dart.dart";
import "../../utils/utils.dart";

final ChatCommand premiumGrantCommand = ChatCommand(
  "grant",
  "Grant a user a premium subscription.",
  Id(
    "premium_grant_command",
    (
      IContext ctx,
      @Description("The user you want to grant premium subscription.")
          IUser user,
      @Description("The duration of the subscription in days.") int days,
    ) async {
      // DatabaseUser dbUser = await ctx.dbUser;
      DatabaseUser targetUser =
          await client.database.getUser(user.id.toString());

      if (targetUser.isPartner) {
        return await respond(
          ctx,
          MessageBuilder.content(
              "This user is a partner. You cannot grant them subscription."),
          hidden: true,
        );
      }

      if (days > 3650 || days < 7) {
        return await respond(
          ctx,
          MessageBuilder.content(
              "Argument days should be between 7-3650 days."),
          hidden: true,
        );
      }

      await targetUser.grantPremium(ctx.user, user, Duration(days: days));

      return await respond(
        ctx,
        MessageBuilder.content(
            "You have extended ${user.mention}'s premium subscription for $days day(s).\nNow ${user.mention} have premium till ${targetUser.premium.until.toUtc().toString().split(" ")[0]}"),
      );
    },
  ),
  checks: [partnerCheck],
);
