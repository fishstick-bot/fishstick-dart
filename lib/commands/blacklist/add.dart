import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_user.dart";
import "../../fishstick_dart.dart";
import "../../utils/utils.dart";

final ChatCommand blacklistAddCommand = ChatCommand(
  "add",
  "Blacklist a user.",
  (
    IContext ctx,
    @Description("The user you want to blacklist.") IUser user,
    @Description("The reason for blacklisting the user.") String reason,
  ) async {
    // DatabaseUser dbUser = await ctx.dbUser;
    DatabaseUser targetUser = await client.database.getUser(user.id.toString());

    if (targetUser.isBanned) {
      return await respond(
        ctx,
        MessageBuilder.content("This user is already blacklisted."),
        hidden: true,
      );
    }

    if (reason.isEmpty) {
      return await respond(
        ctx,
        MessageBuilder.content(
            "You need to provide a reason for blacklisting this user."),
        hidden: true,
      );
    }

    await targetUser.blacklist(reason);

    return await respond(
      ctx,
      MessageBuilder.content(
          "You have blacklisted ${user.mention} for reason: $reason."),
    );
  },
  checks: [ownerCheck],
);
