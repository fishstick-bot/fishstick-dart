import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_user.dart";
// import "../../extensions/context_extensions.dart";
import "../../fishstick_dart.dart";
import "../../utils/utils.dart";

final Group partnerCommand = Group(
  "partner",
  "Grant/Revoke a user partner tier.",
  children: [
    Command(
      "grant",
      "Grant a user a partner tier.",
      (
        Context ctx,
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
      checks: [
        ownerCheck,
      ],
    ),
    Command(
      "revoke",
      "Revoke a user's partner tier.",
      (
        Context ctx,
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
      checks: [
        ownerCheck,
      ],
    ),
  ],
);
