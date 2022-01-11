import "package:nyxx_commands/nyxx_commands.dart";
import "br.dart";
import "stw.dart";

final Group mfaCommand = Group(
  "2fa",
  "Claim your MFA rewards.",
  children: [
    mfaBRCommand,
    mfaSTWCommand,
  ],
  aliases: ["mfa"],
  checks: [],
);
