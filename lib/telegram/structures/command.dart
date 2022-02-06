import "package:teledart/model.dart";

import "../client/client.dart" show TeleBotClient;
import "../../database/database_user.dart";

class Command {
  late final String name;
  late final String description;
  late final Future<void> Function(TeleBotClient, TeleDartMessage, DatabaseUser)
      handle;
  bool isPremiumOnly = false;
  bool isPartnerOnly = false;
  bool isOwnerOnly = false;

  Command(this.name, this.description, this.handle);
}
