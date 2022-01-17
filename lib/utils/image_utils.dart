import "dart:io";
import "dart:math";
import "package:image_extensions/image_extensions.dart";
import "package:fortnite/fortnite.dart";
import "../extensions/fortnite_extensions.dart";

Map<String, Image?> cache = {};

int reduceBy = 4;

class ImageUtils {
  /// fortnite font
  late BitmapFont burbank;

  /// bot logo
  late Image botLogo;

  /// locker icon
  late Image lockerIcon;

  /// discord logo
  late Image discordLogo;

  /// load fonts
  Future<BitmapFont> loadFont() async {
    burbank = readFontZip(
        await File("assets/fonts/BurbankBigRegular-Black.zip").readAsBytes());
    burbank.scaleW = 2;
    burbank.scaleH = 2;
    return burbank;
  }

  /// load images
  Future<void> loadImages() async {
    botLogo = (await loadImage("assets/logo.png"))!;
    lockerIcon = (await loadImage("assets/locker_icon.png"))!;
    discordLogo = (await loadImage("assets/discord.png"))!;
  }

  /// draw fortnite cosmetic
  Future<Image> drawFortniteCosmetic({
    required String icon,
    required String rarity,
    bool isExclusive = false,
  }) async {
    int x = 416 ~/ reduceBy;
    int y = 520 ~/ reduceBy;
    final Image canvas = drawCanvas(x, y);

    drawRadialGradient(
      canvas,
      0,
      0,
      x,
      y,
      x ~/ 2,
      y ~/ 2,
      isExclusive ? Colors.exclusive1 : Colors.gradient1,
      isExclusive ? Colors.exclusive2 : Colors.gradient2,
    );

    drawImage(
      canvas,
      await loadImage(icon) ?? Image(0, 0),
      dstX: (-canvas.height * 0.1).toInt(),
      dstY: 0,
      dstW: canvas.height,
      dstH: canvas.height,
    );

    List<int> rgba =
        Colors.overlayColors[rarity] ?? Colors.overlayColors["common"]!;
    if (isExclusive) {
      rgba = rgba;
    }

    fillShape(
      canvas,
      [
        [0, y],
        [x, y],
        [x, (y * 0.9).toInt()],
        [0, (y * 0.95).toInt()],
      ],
      getColor(rgba[0], rgba[1], rgba[2], (255 * 0.8).toInt()),
    );
    fillShape(
      canvas,
      [
        [0, (y * 0.97).toInt()],
        [x, (y * 0.93).toInt()],
        [x, (y * 0.9).toInt()],
        [0, (y * 0.95).toInt()],
      ],
      getColor(rgba[0], rgba[1], rgba[2], (255 * 0.9).toInt()),
    );

    return removeAlphaChannel(canvas);
  }

  /// draw locker
  Future<Image> drawLocker({
    required List<AthenaCosmetic> cosmetics,
  }) async {
    int padding = 100 ~/ reduceBy;
    int itemX = 416 ~/ reduceBy;
    int itemY = 520 ~/ reduceBy;

    int itemsInARow = (sqrt(cosmetics.length).ceilToDouble()).toInt();

    int x = itemX * itemsInARow + padding + itemsInARow * padding;
    int y = itemY * (cosmetics.length / itemsInARow).ceilToDouble().toInt() +
        itemsInARow * padding +
        itemY;

    /// create canvas
    final Image canvas = drawCanvas(x, y);

    /// draw background
    drawRadialGradient(
      canvas,
      0,
      0,
      x,
      y,
      x ~/ 2,
      y ~/ 2,
      Colors.bg1,
      Colors.bg2,
    );

    int fX = padding;
    int fY = padding;
    int numRendered = 0;

    Image icon;
    for (final cosmetic in cosmetics) {
      icon = await loadImage(cosmetic.imagePath) ?? Image(0, 0);

      fillRect(
        canvas,
        fX - padding ~/ 4,
        fY - padding ~/ 4,
        fX + itemX + padding ~/ 4,
        fY + itemY + padding ~/ 4,
        Colors.white,
      );
      drawImage(
        canvas,
        icon,
        dstX: fX,
        dstY: fY,
      );

      fX += itemX + padding;
      numRendered++;
      if (numRendered % itemsInARow == 0) {
        fX = padding;
        fY += itemY + padding;
      }
    }

    drawImage(
      canvas,
      botLogo,
      dstX: canvas.width - itemY,
      dstY: canvas.height - itemY,
      dstW: (itemY * 0.9).toInt(),
      dstH: (itemY * 0.9).toInt(),
    );

    int fontSize = 20;

    drawString(
      canvas,
      burbank
        ..size = fontSize
        ..italic = true,
      canvas.width - itemY - "discord.gg/fishstick".length * fontSize,
      canvas.height - (itemY ~/ 2) - fontSize,
      "discord.gg/fishstick",
      color: Colors.white,
    );

    drawImage(
      canvas,
      lockerIcon,
      dstX: (itemY * 0.1).toInt(),
      dstY: canvas.height - itemY,
      dstW: (itemY * 0.9).toInt(),
      dstH: (itemY * 0.9).toInt(),
    );

    /// add number of cosmetics string after locker icon

    return canvas;
  }
}

class Colors {
  static int get white => getColor(255, 255, 255, 255);

  /// background color for fortnite images
  static int get background => getColor(19, 105, 199);

  /// gradient color 1 for fortnite images
  static int get bg1 => getColor(22, 134, 224);

  /// gradient color 2 for fortnite images
  static int get bg2 => getColor(14, 80, 153);

  /// gradient color 1 background for fortnite card
  static int get gradient1 => getColor(45, 150, 235);

  /// gradient color 2 background for fortnite card
  static int get gradient2 => getColor(14, 100, 194);

  /// exclusive color 1 background for fortnite card
  static int get exclusive1 => getColor(208, 142, 39);

  /// exclusive color 2 background for fortnite card
  static int get exclusive2 => getColor(252, 220, 84);

  /// colors for fortnite rarities
  static Map<String, List<int>> get overlayColors => {
        "common": [96, 170, 58],
        "uncommon": [96, 170, 58],
        "rare": [73, 172, 242],
        "epic": [177, 91, 226],
        "legendary": [211, 120, 65],
        "marvel": [168, 53, 56],
        "dark": [179, 62, 187],
        "dc": [80, 97, 122],
        "icon": [43, 134, 135],
        "lava": [185, 102, 100],
        "frozen": [148, 215, 244],
        "shadow": [66, 64, 63],
        "starwars": [231, 196, 19],
        "slurp": [0, 233, 176],
        "platform": [117, 108, 235],
        "gaminglegends": [117, 108, 235],
      };
}
