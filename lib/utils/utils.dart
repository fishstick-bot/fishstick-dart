import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../extensions/context_extensions.dart";
import "../fishstick_dart.dart";

RegExp numberFormatRegex = RegExp(r"(?<=\d)(?=(\d{3})+(?!\d))");

/// notify bot owner
Future<void> notifyAdministrator(
  String message, {
  String? title,
  DiscordColor? color,
}) async {
  try {
    IUser owner = await client.bot.fetchUser(Snowflake(client.config.ownerId));

    await owner.sendMessage(
      MessageBuilder.embed(
        EmbedBuilder()
          ..title = title ?? "Fishstick Event"
          ..color = color ?? DiscordColor.blue
          ..timestamp = DateTime.now()
          ..footer = (EmbedFooterBuilder()
            ..text = client.footerText
            ..iconUrl = client.bot.self.avatarURL(format: "png"))
          ..description = message,
      ),
    );
  } catch (e) {
    print("An exception occured while notifying bot owner: ${e.toString()}");
  }
}

/// notify premium grant event
Future<void> notifyGrantPremiumEvent({
  required IUser user,
  required IUser partner,
  required Duration duration,
}) async {
  return await notifyAdministrator(
      "Partner ${partner.tag} has granted ${user.tag} premium status for ${duration.inDays} day(s).\n```\nPartner ID: ${partner.id}\nUser ID: ${user.id}\nOperation: Grant Premium Subscription for ${duration.inDays} day(s).\n```");
}

/// notify premium revoke event
Future<void> notifyRevokePremiumEvent({
  required IUser user,
  required IUser partner,
}) async {
  return await notifyAdministrator(
      "Partner ${partner.tag} has revoked ${user.tag} premium status.\n```\nPartner ID: ${partner.id}\nUser ID: ${user.id}\nOperation: Revoke Premium Subscription.\n```");
}

/// notify error event
Future<void> notifyErrorEvent({
  required String source,
  required String error,
}) async {
  return await notifyAdministrator(
    "```\nSource: $source\nError: $error\n```",
    title: "An error occurred!",
    color: DiscordColor.red,
  );
}

/// check if user is premium
Check premiumCheck =
    Check((ctx) async => (await ctx.dbUser).isPremium, "premium-check");

/// check if user is partner
Check partnerCheck =
    Check((ctx) async => (await ctx.dbUser).isPartner, "partner-check");

/// check if user is owner of bot
Check ownerCheck = Check(
    (ctx) async => ctx.user.id.toString() == client.config.ownerId,
    "owner-check");

/// override respond function
Future<IMessage> respond(
  Context ctx,
  MessageBuilder builder, {
  bool hidden = false,
}) async {
  if (ctx is InteractionContext) {
    return await ctx.respond(builder, hidden: hidden);
  } else {
    return await ctx.respond(builder);
  }
}
