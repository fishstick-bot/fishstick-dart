import "package:nyxx_commands/nyxx_commands.dart";
import "grant.dart";
import "revoke.dart";
import "check.dart";

final Group premiumCommand = Group(
  "premium",
  "Grant/Revoke a user's premium subscription.",
  children: [
    premiumGrantCommand,
    premiumRevokeCommand,
    premiumCheckCommand,
  ],
  aliases: ["vip"],
);
