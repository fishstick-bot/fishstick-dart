import "dart:convert";
import "dart:async";

import "package:dio/dio.dart" as dio;

import "package:nyxx/nyxx.dart";
import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart";
import "package:shelf_router/shelf_router.dart";

import "../client/client.dart";

class TopGGSystemJob {
  final String name = "top_gg";
  final int _port = 6000;

  /// main client
  final Client client;

  TopGGSystemJob(this.client);

  /// run the task
  Future<void> run() async {
    try {
      client.logger.info("[TASK:$name] starting...");

      final Router router = Router();
      final handler =
          Pipeline().addMiddleware(logRequests()).addHandler(router);

      await serve(handler, "localhost", _port)
        ..autoCompress = true
        ..handleError((dynamic error) {
          // IGNORE IG
        });

      var owner =
          await client.bot.fetchUser(client.config.ownerId.toSnowflake());

      router.post(
        "/webhooks/topgg",
        (Request req) async {
          try {
            if (req.headers["authorization"] == null ||
                req.headers["authorization"] != client.config.webhookKey) {
              return Response(
                401,
                body: JsonEncoder.withIndent(" " * 2).convert({
                  "success": false,
                  "error": "unauthorized",
                }),
                headers: {
                  "content-type": "application/json",
                },
              );
            }

            var body =
                jsonDecode(await req.readAsString()) as Map<String, dynamic>;
            if (body.isNotEmpty) {
              var user = await client.database.getUser(body["user"] as String);

              client.logger.info(
                  "[TASK:$name] ${body["user"]} voted the bot on top.gg, granting them premium for 12 hours.");
              await user.grantPremium(
                owner,
                await client.bot
                    .fetchUser((body["user"] as String).toSnowflake()),
                user.premium.tier,
                Duration(hours: 12),
              );
            }
          } catch (e) {
            client.logger.shout("[TASK:$name] error: $e");
          }

          return Response.ok(
            JsonEncoder.withIndent(" " * 2).convert({
              "success": true,
            }),
            headers: {
              "Content-Type": "application/json",
            },
          );
        },
      );

      Timer.periodic(
        Duration(minutes: 10),
        (timer) async {
          final int totalGuilds =
              (await client.shardingPlugin.getCachedGuilds())
                  .fold<int>(0, (a, b) => a + b);
          client.logger.info(
              "[TASK:$name] reporting total guilds $totalGuilds to top.gg");
          await dio.Dio().post(
            "https://top.gg/api/bots/750967237191532575/stats",
            data: {
              "server_count": totalGuilds,
            },
          );
        },
      );
    } catch (e) {
      client.logger.shout(
          "[TASK:$name] An unexpected error occured retrying in 30seconds: $e");
      await Future.delayed(Duration(seconds: 30), () async => await run());
    }
    return;
  }
}
