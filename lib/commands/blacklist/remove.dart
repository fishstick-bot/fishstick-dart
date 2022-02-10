import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../database/database_user.dart";
import "../../fishstick_dart.dart";
import "../../utils/utils.dart";

final ChatCommand blacklistRemoveCommand = ChatCommand(
  "remove",
  "Unblacklist a user.",
  (
    IContext ctx,
    @Description("The user you want to remove from blacklist.") IUser user,
  ) async {
    // DatabaseUser dbUser = await ctx.dbUser;
    DatabaseUser targetUser = await client.database.getUser(user.id.toString());

    if (!targetUser.isBanned) {
      return await respond(
        ctx,
        MessageBuilder.content("This user is not blacklisted."),
        hidden: true,
      );
    }

    await targetUser.unblacklist();

    return await respond(
      ctx,
      MessageBuilder.content(
          "You have removed ${user.mention} from blacklist."),
    );
  },
  checks: [ownerCheck],
);
