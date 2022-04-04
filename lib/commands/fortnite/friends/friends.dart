import "package:nyxx_commands/nyxx_commands.dart";

import "../../../utils/utils.dart";

import "remove_all.dart";

final ChatGroup friendsCommand = ChatGroup(
  "friends",
  "Manage your fortnite friends list",
  children: [
    nukeFriendListCommand,
  ],
  aliases: ["f"],
  checks: [premiumCheck],
);
