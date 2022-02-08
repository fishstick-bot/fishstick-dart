import "dart:async";

import "package:nyxx/nyxx.dart";
import "package:logging/logging.dart";
import "package:cron/cron.dart";

import "../client/client.dart";

import "update_cosmetics_cache.dart";
import "premium_role_sync.dart";
import "claim_daily.dart";

/// Handles all the system jobs
class SystemJobsPlugin extends BasePlugin {
  late final Client _client;

  /// cron manager
  late final Cron _cron;

  /// update cosmetics cache system job
  late final UpdateCosmeticsCacheSystemJob updateCosmeticsCacheSystemJob;

  /// update cosmetics cache system job
  late final Timer _updateCosmeticsCacheSystemJobTimer;

  /// premium role sync system job
  late final PremiumRoleSyncSystemJob premiumRoleSyncSystemJob;

  /// premium role sync system job
  late final Timer _premiumRoleSyncSystemJobTimer;

  /// claim daily system job
  late final ClaimDailySystemJob claimDailySystemJob;

  /// claim daily system job
  late final ScheduledTask _claimDailySystemJobTimer;

  /// Creates a new instance of [SystemJobsPlugin]
  SystemJobsPlugin(this._client);

  /// Registers all the system jobs
  @override
  Future<void> onRegister(INyxx nyxx, Logger logger) async {
    _cron = Cron();
    logger.info("Registering update cosmetics cache system job");
    updateCosmeticsCacheSystemJob = UpdateCosmeticsCacheSystemJob();
    logger.info("Registering premium role sync system job");
    premiumRoleSyncSystemJob = PremiumRoleSyncSystemJob();
    logger.info("Registering claim daily system job");
    claimDailySystemJob = ClaimDailySystemJob(_client);
  }

  /// Schedule all the system jobs
  @override
  void onBotStart(INyxx nyxx, Logger logger) async {
    try {
      updateCosmeticsCacheSystemJob.run();

      logger.info(
          "Scheduling update cosmetics cache system job to run every ${updateCosmeticsCacheSystemJob.runDuration.inHours} hours.");
      _updateCosmeticsCacheSystemJobTimer =
          Timer.periodic(updateCosmeticsCacheSystemJob.runDuration, (_) async {
        await updateCosmeticsCacheSystemJob.run();
      });

      logger.info(
          "Scheduling premium role sync system job to run every ${premiumRoleSyncSystemJob.runDuration.inHours} hours.");
      _premiumRoleSyncSystemJobTimer =
          Timer.periodic(premiumRoleSyncSystemJob.runDuration, (_) async {
        await premiumRoleSyncSystemJob.run();
      });

      logger.info(
          "Scheduling claim daily system job to run every day at 0:00 UTC.");
      _claimDailySystemJobTimer =
          _cron.schedule(Schedule.parse("1 0 * * *"), () async {
        await claimDailySystemJob.run();
      });
    } on Exception catch (e) {
      logger.severe("Failed to start system jobs", e);
    }
  }

  /// Unschedule all system jobs
  @override
  Future<void> onBotStop(INyxx nyxx, Logger logger) async {
    try {
      logger.info("Unscheduling update cosmetics cache system job.");
      _updateCosmeticsCacheSystemJobTimer.cancel();
      logger.info("Unscheduling premium role sync system job.");
      _premiumRoleSyncSystemJobTimer.cancel();
      logger.info("Unscheduling claim daily system job.");
      await _claimDailySystemJobTimer.cancel();
      logger.info("Closing cron manager.");
      await _cron.close();
    } on Exception catch (e) {
      logger.severe("Failed to cancel system jobs", e);
    }
  }
}
