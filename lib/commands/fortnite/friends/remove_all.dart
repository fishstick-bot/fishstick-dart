import "package:nyxx_commands/nyxx_commands.dart";
import "package:nyxx_interactions/nyxx_interactions.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";
import "../../../utils/friends_manager.dart";

final ChatCommand nukeFriendListCommand = ChatCommand(
  "remove-all",
  "Clear your fortnite friend list.",
  Id(
    "remove_all_friends_command",
    (IContext ctx) async {
      DatabaseUser dbUser = await ctx.dbUser;
      dbUser.fnClientSetup();

      final FriendsManager friendsManager = FriendsManager(dbUser.fnClient);
      await friendsManager.init();

      var confirmationMsg = await ctx.takeConfirmation(
          "Are you sure you want to remove ${friendsManager.friends.length} friends from your friend list?");
      if (confirmationMsg == null) {
        return null;
      }

      await friendsManager.clearFriendList();

      await confirmationMsg.edit(
        ComponentMessageBuilder()
          ..content = "Done! Removed ${friendsManager.friends.length} friends."
          ..embeds = []
          ..componentRows = [],
      );
    },
  ),
  checks: [],
);
