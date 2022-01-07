import "package:nyxx_commands/nyxx_commands.dart";
import "grant.dart";
import "revoke.dart";

final Group partnerCommand = Group(
  "partner",
  "Grant/Revoke a user partner tier.",
  children: [
    grantPartnerCommand,
    revokePartnerCommand,
  ],
);
