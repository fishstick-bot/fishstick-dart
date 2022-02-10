import "package:nyxx_commands/nyxx_commands.dart";
import "br.dart";
import "stw.dart";

final ChatGroup mfaCommand = ChatGroup(
  "2fa",
  "Claim your MFA rewards.",
  children: [
    mfaBRCommand,
    mfaSTWCommand,
  ],
  aliases: ["mfa"],
  checks: [],
);
