# Fishstick Bot

A multipurpose fortnite bot coded in dart.

---

## Steps to Run

-   Make a file: `lib/private.dart`.

-   Copy content of `lib/private.example.dart` to `lib/private.dart`.

-   Edit the fields `discordDevToken`, `discordProdToken`, `mongoDbUri` to your actual tokens, urls.

-   Edit field `_developmentMode` inside `lib/config.dart` (do `true` if its your main bot).

-   Run the following the command to compile the code to exe: `dart compile exe --o build/bot.exe bin/fishstick_dart.dart`.

-   Run the exe with command: `build/bot.exe`.
