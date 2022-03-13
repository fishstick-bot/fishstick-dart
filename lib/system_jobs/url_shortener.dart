import "dart:convert";

import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart";
import "package:shelf_router/shelf_router.dart";

import "../client/client.dart";

class UrlShortenerSystemJob {
  final String name = "url_shortener";
  final int _port = 6970;

  /// main client
  final Client client;

  UrlShortenerSystemJob(this.client);

  Future<String> addUrl(String url) async {
    return (await client.database.createTinyUrl(url)).code;
  }

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

      router.get(
        "/tinyurl/<uuid>",
        (Request req, String uuid) async {
          var found = await client.database.getTinyUrl(uuid);
          if (found == null) {
            return Response.ok(
              JsonEncoder.withIndent(" " * 2).convert({
                "success": false,
                "message": "No url found with code $uuid",
              }),
            );
          }

          String html = """
<!DOCTYPE html>
<html>
    <head>
        <title>Fishstick URL Shortener</title>
        <meta charset="UTF-8" />
        <meta
            name="description"
            content="Fishstick URL Shortener - Made for Fishstick bot."
        />
        <meta name="keywords" content="Fishstick, Discord, Url, tinyurl" />
        <meta name="author" content="Vanxh" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="refresh" content="3; URL=${found.targetUrl}" />
        <script
            async
            src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-9981649893294945"
            crossorigin="anonymous"
        ></script>
    </head>
    <body>
        <p style="text-align: center">Redirecting in 3 seconds...</p>
    </body>
</html>
""";

          return Response.ok(
            html,
            headers: {
              "Content-Type": "text/html",
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
