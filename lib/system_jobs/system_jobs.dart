import "dart:async";

import "package:nyxx/nyxx.dart";
import "package:logging/logging.dart";

import "../client/client.dart";

import "update_cosmetics_cache.dart";
import "premium_role_sync.dart";

/// Handles all the system jobs
class SystemJobsPlugin extends BasePlugin {
  final Client _client;

  /// update cosmetics cache system job
  late UpdateCosmeticsCacheSystemJob updateCosmeticsCacheSystemJob;

  /// update cosmetics cache system job
  late Timer _updateCosmeticsCacheSystemJobTimer;

  /// premium role sync system job
  late PremiumRoleSyncSystemJob premiumRoleSyncSystemJob;

  /// premium role sync system job
  late Timer _premiumRoleSyncSystemJobTimer;

  /// Creates a new instance of [SystemJobsPlugin]
  SystemJobsPlugin(this._client);

  /// Registers all the system jobs
  @override
  Future<void> onRegister(INyxx nyxx, Logger logger) async {
    updateCosmeticsCacheSystemJob = UpdateCosmeticsCacheSystemJob();
    _client.logger.info("Registering update cosmetics cache system job");
    premiumRoleSyncSystemJob = PremiumRoleSyncSystemJob();
    _client.logger.info("Registering premium role sync system job");
  }

  /// Schedule all the system jobs
  @override
  void onBotStart(INyxx nyxx, Logger logger) async {
    try {
      updateCosmeticsCacheSystemJob.run();

      _client.logger.info(
          "Scheduling update cosmetics cache system job to run every ${updateCosmeticsCacheSystemJob.runDuration.inHours} hours.");
      _updateCosmeticsCacheSystemJobTimer =
          Timer.periodic(updateCosmeticsCacheSystemJob.runDuration, (_) async {
        await updateCosmeticsCacheSystemJob.run();
      });

      _client.logger.info(
          "Scheduling premium role sync system job to run every ${premiumRoleSyncSystemJob.runDuration.inHours} hours.");
      _premiumRoleSyncSystemJobTimer =
          Timer.periodic(premiumRoleSyncSystemJob.runDuration, (_) async {
        await premiumRoleSyncSystemJob.run();
      });
    } on Exception catch (e) {
      _client.logger.severe("Failed to start system jobs", e);
    }
  }

  /// Unschedule all system jobs
  @override
  Future<void> onBotStop(INyxx nyxx, Logger logger) async {
    try {
      _updateCosmeticsCacheSystemJobTimer.cancel();
      _premiumRoleSyncSystemJobTimer.cancel();
    } on Exception catch (e) {
      _client.logger.severe("Failed to cancel system jobs", e);
    }
  }
}
