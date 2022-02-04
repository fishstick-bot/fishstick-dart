import "dart:async";
import "package:numeral/numeral.dart";
import "package:logging/logging.dart";
import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";

import "../database/database.dart";
import "../config.dart";

import "../utils/utils.dart";
import "../utils/image_utils.dart";
import "../utils/commands_handler.dart";

import "../system_jobs/system_jobs.dart";

import "../commands/info/ping.dart";
import "../commands/info/invite.dart";
import "../commands/info/info.dart";
import "../commands/info/help.dart";
import "../commands/autopost_stw_alerts/autopost.dart";
import "../commands/general/color.dart";
import "../commands/general/settings.dart";
import "../commands/premium/premium.dart";
import "../commands/partner/partner.dart";
import "../commands/blacklist/blacklist.dart";
import "../commands/fortnite/account/login.dart";
import "../commands/fortnite/account/logout.dart";
import "../commands/fortnite/account/account.dart";
import "../commands/fortnite/account/launch.dart";
import "../commands/fortnite/vbucks/vbucks.dart";
import "../commands/fortnite/sac/sac.dart";
import "../commands/fortnite/mfa/mfa.dart";
import "../commands/fortnite/afk.dart";
import "../commands/fortnite/overview/overview.dart";
import "../commands/fortnite/locker/locker.dart";
import "../commands/fortnite/stw/resources.dart";
import "../commands/fortnite/stw/skip_tutorial.dart";
import "../commands/fortnite/stw/homebase_name.dart";
import "../commands/fortnite/stw/upgrade.dart";
import "../commands/fortnite/stw/storm_king.dart";
import "../commands/fortnite/stw/pending_difficulty_rewards.dart";
import "../commands/fortnite/stw/survivor_squad_presets/survivor_squad_presets.dart";

class Client {
  /// Configuration for the client
  late final Config config = Config();

  /// logger
  final Logger logger = Logger("BOT");

  /// The nyxx client
  late INyxxWebsocket bot;

  /// The database for the bot
  late Database database;

  /// Image utils for the client
  late ImageUtils imageUtils;

  /// Cached cosmetics for the client
  List<Map<String, dynamic>> cachedCosmetics = [];

  /// System jobs manager
  late SystemJobsPlugin systemJobs;

  // Footer text
  String footerText = "discord.gg/fishstick";

  /// prefix for commands
  String prefix = ".";

  /// global commands cooldown
  int commandsCooldown = 4;

  Client() {
    /// setup logger
    Logger.root.level = Level.INFO;

    /// setup system jobs manager
    systemJobs = SystemJobsPlugin();

    /// setup commands
    final CommandsPlugin _commands = CommandsPlugin(
      prefix: dmOr((_) => "."),
      guild: config.developmentMode ? Snowflake(config.developmentGuild) : null,
      options: CommandsOptions(
        logErrors: true,
        acceptBotCommands: false,
        acceptSelfCommands: false,
        autoAcknowledgeInteractions: true,
        hideOriginalResponse: false,
      ),
    );

    /// register the commands
    _commands.addCommand(pingCommand);
    _commands.addCommand(inviteCommand);
    _commands.addCommand(infoCommand);
    _commands.addCommand(helpCommand);
    _commands.addCommand(autopostCommand);
    _commands.addCommand(colorCommand);
    _commands.addCommand(settingsCommand);
    _commands.addCommand(premiumCommand);
    _commands.addCommand(partnerCommand);
    _commands.addCommand(blacklistCommand);
    _commands.addCommand(loginCommand);
    _commands.addCommand(logoutCommand);
    _commands.addCommand(accountCommand);
    _commands.addCommand(gameLaunchCommand);
    _commands.addCommand(vbucksCommand);
    _commands.addCommand(affiliateCommand);
    _commands.addCommand(mfaCommand);
    _commands.addCommand(afkCommand);
    _commands.addCommand(overviewCommand);
    _commands.addCommand(resourcesSTWCommand);
    _commands.addCommand(lockerCommand);
    _commands.addCommand(skipTutorialCommand);
    _commands.addCommand(homebaseNameCommand);
    _commands.addCommand(stwUpgradeCommand);
    _commands.addCommand(mskCommand);
    _commands.addCommand(pendingDifficultyRewardsCommand);
    _commands.addCommand(survivorSquadPresetCommand);

    /// handle commands error
    handleCommandsError(this, _commands);

    /// handle commands check
    handleCommandsCheckHandler(_commands, commandsCooldown);

    /// handle commands post call
    handleCommandsPostCall(_commands);

    /// setup database
    database = Database(config.mongoUri);

    /// setup image utils
    imageUtils = ImageUtils(config.apiKey);

    /// setup discord client
    bot = NyxxFactory.createNyxxWebsocket(
      config.token,
      GatewayIntents.allUnprivileged,
      options: ClientOptions(
        initialPresence: PresenceBuilder.of(
          activity: ActivityBuilder.game("/help"),
          status: UserStatus.online,
        ),
        messageCacheSize: 0,
        guildSubscriptions: false,
        dispatchRawShardEvent: true,
      ),
      useDefaultLogger: false,
    )
      ..registerPlugin(Logging())
      ..registerPlugin(CliIntegration())
      ..registerPlugin(IgnoreExceptions())
      ..registerPlugin(_commands)
      ..registerPlugin(systemJobs);

    return;
  }

  /// Start the client.
  /// This will connect to the bot to discord and database.
  Future<void> start() async {
    int _start;

    _start = DateTime.now().millisecondsSinceEpoch;
    await database.connect();
    logger.info(
        "Connected to database [${(DateTime.now().millisecondsSinceEpoch - _start).toStringAsFixed(2)}ms]");

    _start = DateTime.now().millisecondsSinceEpoch;
    await bot.connect();
    logger.info(
        "Connected to discord [${(DateTime.now().millisecondsSinceEpoch - _start).toStringAsFixed(2)}ms]");

    Timer.periodic(Duration(minutes: 10), (timer) {
      bot.setPresence(
        PresenceBuilder.of(
          activity: ActivityBuilder.game(
              "/help | ${Numeral(bot.guilds.length).value()} Guilds"),
          status: UserStatus.online,
        ),
      );
    });

    return;
  }

  /// encrypt a string
  String encryptString(String text) => encrypt(text);

  /// decrypt a string
  String decryptString(String text) => decrypt(text);
}
