import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../extensions/context_extensions.dart";
import "../../fishstick_dart.dart";

final Group premiumCommand = Group(
  "premium",
  "Grant/Revoke a user's premium subscription.",
  children: [
    Command(
      "grant",
      "Grant a user a premium subscription.",
      (Context ctx) async {
        print("GRANT");
      },
    ),
    Command(
      "revoke",
      "Revoke a user's premium subscription.",
      (Context ctx) async {
        print("REVOKE");
      },
    ),
  ],
  aliases: ["prem"],
);
