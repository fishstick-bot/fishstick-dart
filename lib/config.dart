import "private.dart";

class Config {
  static final bool _developmentMode = true;

  /// is the bot in development mode
  bool get developmentMode => _developmentMode;

  /// guild id to register commands on while in development mode.
  String get developmentGuild => "877595218948554752";

  /// the bot's owner id
  String get ownerId => "727224012912197652";

  /// support server invite
  String get supportServer => "https://discord.gg/fishstick";

  /// encryption key
  String get encryptionKey => Privates.encryptionKey;

  /// the bot's token
  String get token =>
      _developmentMode ? Privates.discordDevToken : Privates.discordProdToken;

  /// mongo db uri
  String get mongoUri => Privates.mongoDbUri;
}
