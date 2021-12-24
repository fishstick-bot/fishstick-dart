import "private.dart";

class Config {
  static final bool _developmentMode = true;

  /// is the bot in development mode
  bool get developmentMode => _developmentMode;

  /// the bot's token
  String get token => _developmentMode ? discordDevToken : discordProdToken;
}
