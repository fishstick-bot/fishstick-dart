import "dart:async";

import "package:nyxx/nyxx.dart";
import "package:nyxx_sharding/nyxx_sharding.dart";
import "package:logging/logging.dart";
import "package:cron/cron.dart";

import "../client/client.dart";

import "update_cosmetics_cache.dart";
import "catalog_manager.dart";
import "premium_role_sync.dart";
import "claim_daily.dart";
import "free_llamas.dart";
import "collect_research.dart";
import "auto_research.dart";
import "url_shortener.dart";
import "topgg.dart";
import "stw_missions.dart";

/// Handles all the system jobs
class SystemJobsPlugin extends BasePlugin {
  late final Client _client;

  /// cron manager
  late final Cron _cron;

  /// update cosmetics cache system job
  late final UpdateCosmeticsCacheSystemJob updateCosmeticsCacheSystemJob;

  /// update cosmetics cache system job
  late final Timer _updateCosmeticsCacheSystemJobTimer;

  /// catalog manager system job
  late final CatalogManagerSystemJob catalogManagerSystemJob;

  /// catalog manager system job
  late final Timer _catalogManagerSystemJobTimer;

  /// premium role sync system job
  late final PremiumRoleSyncSystemJob premiumRoleSyncSystemJob;

  /// premium role sync system job
  late final Timer _premiumRoleSyncSystemJobTimer;

  /// claim daily system job
  late final ClaimDailySystemJob claimDailySystemJob;

  /// claim daily system job
  late final ScheduledTask _claimDailySystemJobTimer;

  /// free llamas system job
  late final ClaimFreeLlamasSystemJob freeLlamasSystemJob;

  /// free llamas system job
  late final Timer _freeLlamasSystemJobTimer;

  /// collect research system job
  late final ClaimResearchPointsSystemJob collectResearchPointsSystemJob;

  /// collect research system job
  late final Timer _collectResearchPointsSystemJobTimer;

  /// auto research system job
  late final AutoResearchSystemJob autoResearchSystemJob;

  /// auto research system job
  late final Timer _autoResearchSystemJobTimer;

  /// url shortener system job
  late final UrlShortenerSystemJob urlShortenerSystemJob;

  /// topgg system job
  late final TopGGSystemJob topGGSystemJob;

  /// stw missions system job
  late final STWMissionsSystemJob stwMissionsSystemJob;

  /// stw missions system job
  late final ScheduledTask _stwMissionsSystemJobTimer;

  /// Creates a new instance of [SystemJobsPlugin]
  SystemJobsPlugin(this._client);

  /// Registers all the system jobs
  @override
  Future<void> onRegister(INyxx nyxx, Logger logger) async {
    _cron = Cron();
    logger.info("Registering update cosmetics cache system job");
    updateCosmeticsCacheSystemJob = UpdateCosmeticsCacheSystemJob();
    logger.info("Registering catalog manager system job");
    catalogManagerSystemJob = CatalogManagerSystemJob();
    logger.info("Registering premium role sync system job");
    premiumRoleSyncSystemJob = PremiumRoleSyncSystemJob();
    logger.info("Registering claim daily system job");
    claimDailySystemJob = ClaimDailySystemJob(_client);
    logger.info("Registering free llamas system job");
    freeLlamasSystemJob = ClaimFreeLlamasSystemJob(_client);
    logger.info("Registering collect research points system job");
    collectResearchPointsSystemJob = ClaimResearchPointsSystemJob(_client);
    logger.info("Registering auto research system job");
    autoResearchSystemJob = AutoResearchSystemJob(_client);
    logger.info("Registering url shortener system job");
    urlShortenerSystemJob = UrlShortenerSystemJob(_client);
    logger.info("Registering topgg system job");
    topGGSystemJob = TopGGSystemJob(_client);
    logger.info("Registering stw missions system job");
    stwMissionsSystemJob = STWMissionsSystemJob(_client);
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

      catalogManagerSystemJob.run();

      logger.info(
          "Scheduling catalog manager system job to run every ${catalogManagerSystemJob.runDuration.inHours} hours.");
      _catalogManagerSystemJobTimer =
          Timer.periodic(catalogManagerSystemJob.runDuration, (_) async {
        await catalogManagerSystemJob.run();
      });

      if (!shardIds.contains(0)) {
        return;
      }

      urlShortenerSystemJob.run();
      topGGSystemJob.run();

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

      logger.info("Scheduling free llamas system job to run every 15 minutes.");
      _freeLlamasSystemJobTimer =
          Timer.periodic(Duration(minutes: 15), (_) async {
        await freeLlamasSystemJob.run();
      });

      logger.info(
          "Scheduling collect research points system job to run every 12 hours.");
      _collectResearchPointsSystemJobTimer =
          Timer.periodic(Duration(hours: 12), (_) async {
        await collectResearchPointsSystemJob.run();
      });

      logger.info("Scheduling auto research system job to run every 16 hours.");
      _autoResearchSystemJobTimer =
          Timer.periodic(Duration(hours: 16), (_) async {
        await autoResearchSystemJob.run();
      });

      /// RUN AUTO RESEARCH SYSTEM JOBS IF BOT IS SUCCESSFULLY BE ONLINE FOR 5MINS.
      Future.delayed(Duration(minutes: 5), () async {
        await collectResearchPointsSystemJob.run();
        await autoResearchSystemJob.run();
      });

      if (!_client.config.developmentMode) {
        stwMissionsSystemJob.run();
      }

      logger
          .info("Scheduling stw missions system job to run daily at 0:00 UTC.");
      _stwMissionsSystemJobTimer =
          _cron.schedule(Schedule.parse("1 0 * * *"), () async {
        await stwMissionsSystemJob.run();
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

      logger.info("Unscheduling catalog manager system job.");
      _catalogManagerSystemJobTimer.cancel();

      if (!shardIds.contains(0)) {
        return;
      }

      logger.info("Unscheduling premium role sync system job.");
      _premiumRoleSyncSystemJobTimer.cancel();

      logger.info("Unscheduling claim daily system job.");
      await _claimDailySystemJobTimer.cancel();

      logger.info("Unscheduling free llamas system job.");
      _freeLlamasSystemJobTimer.cancel();

      logger.info("Unscheduling collect research points system job.");
      _collectResearchPointsSystemJobTimer.cancel();

      logger.info("Unscheduling auto research system job.");
      _autoResearchSystemJobTimer.cancel();

      logger.info("Unscheduling stw missions system job.");
      await _stwMissionsSystemJobTimer.cancel();

      logger.info("Closing cron manager.");
      await _cron.close();
    } on Exception catch (e) {
      logger.severe("Failed to cancel system jobs", e);
    }
  }
}
