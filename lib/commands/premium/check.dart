import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_user.dart";
import "../../fishstick_dart.dart";
import "../../utils/utils.dart";

final ChatCommand premiumCheckCommand = ChatCommand(
  "check",
  "Check a user's premium subscription.",
  (
    IContext ctx,
    @Description("The user you want to check premium subscription of.")
        IUser user,
  ) async {
    // DatabaseUser dbUser = await ctx.dbUser;
    DatabaseUser targetUser = await client.database.getUser(user.id.toString());

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
);
