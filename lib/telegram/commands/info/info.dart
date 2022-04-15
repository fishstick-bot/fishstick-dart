import "dart:io";
import "package:time_ago_provider/time_ago_provider.dart" show formatFull;
import "package:pubspec_yaml/pubspec_yaml.dart";
import "../../structures/command.dart";
import "../../../utils/utils.dart";

final Command info = Command(
  "info",
  "Get basic bot info.",
  (client, msg, user) async {
    final pubspecYaml =
        (await File("pubspec.yaml").readAsString()).toPubspecYaml();

    await msg.reply(
      "*Fishstick Bot Information*\nWebsite \\- https://fishstickbot\\.com\n\nUptime \\- ${formatFull(client.startTime).replaceAll(".", "\\.").replaceAll("-", "//-")}\nFishstick dart ${pubspecYaml.version.toString().split("(")[1].replaceAll(")", "").replaceAll(".", "\\.").replaceAll("-", "\\-")} \\| Dart SDK ${dartVersion.replaceAll(".", "\\.").replaceAll("-", "\\-")}",
      parse_mode: "MarkdownV2",
    );
  },
);
