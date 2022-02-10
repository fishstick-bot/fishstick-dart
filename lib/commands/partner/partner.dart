import "package:nyxx_commands/nyxx_commands.dart";
import "grant.dart";
import "revoke.dart";

final ChatGroup partnerCommand = ChatGroup(
  "partner",
  "Grant/Revoke a user partner tier.",
  children: [
    grantPartnerCommand,
    revokePartnerCommand,
  ],
);
