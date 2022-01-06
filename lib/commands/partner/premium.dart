import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_user.dart";
// import "../../extensions/context_extensions.dart";
import "../../fishstick_dart.dart";
import "../../utils/utils.dart";

final Group premiumCommand = Group(
  "premium",
  "Grant/Revoke a user's premium subscription.",
  children: [
    Command(
      "grant",
      "Grant a user a premium subscription.",
      (
        Context ctx,
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

        if (days > 365 || days < 7) {
          return await respond(
            ctx,
            MessageBuilder.content(
                "Argument days should be between 7-365 days."),
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
      checks: [
        partnerCheck,
      ],
    ),
    Command(
      "revoke",
      "Revoke a user's premium subscription.",
      (
        Context ctx,
        @Description("The user you want to revoke premium subscription of.")
            IUser user,
      ) async {
        // DatabaseUser dbUser = await ctx.dbUser;
        DatabaseUser targetUser =
            await client.database.getUser(user.id.toString());

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
    ),
    Command(
      "check",
      "Check a user's premium subscription.",
      (
        Context ctx,
        @Description("The user you want to check premium subscription of.")
            IUser user,
      ) async {
        // DatabaseUser dbUser = await ctx.dbUser;
        DatabaseUser targetUser =
            await client.database.getUser(user.id.toString());

        if (targetUser.isPartner) {
          return await respond(
            ctx,
            MessageBuilder.content("This user is a partner."),
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

        return await respond(
          ctx,
          MessageBuilder.content(
              "${user.mention}'s premium subscription is valid till: ${targetUser.premium.until.toUtc().toString().split(" ")[0]}"),
        );
      },
    ),
  ],
  aliases: ["vip"],
);
