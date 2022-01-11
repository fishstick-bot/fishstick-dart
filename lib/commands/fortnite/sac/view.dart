import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
import "../../../fishstick_dart.dart";
import "../../../../database/database_user.dart";
import "../../../../extensions/context_extensions.dart";

final Command affiliateViewCommand = Command(
  "view",
  "View your supported creator in the item shop.",
  (Context ctx) async {
    DatabaseUser dbUser = await ctx.dbUser;
    dbUser.fnClientSetup();
    await dbUser.fnClient.commonCore.init();

    final EmbedBuilder embed = EmbedBuilder()
      ..author = (EmbedAuthorBuilder()
        ..name = ctx.user.username
        ..iconUrl = ctx.user.avatarURL(format: "png"))
      ..color = DiscordColor.fromHexString(dbUser.color)
      ..title = "${dbUser.activeAccount.displayName}'s Supported Creator"
      ..description = dbUser.fnClient.commonCore.supportedCreator.isEmpty
          ? "You are not supporting any creator.\n\nYou can set your supported creator with:\n• /sac change **AABBCCDDEEFF**"
          : "Current supported creator: **${dbUser.fnClient.commonCore.supportedCreator}**\n\nYou can change your supported creator with:\n• /sac change **AABBCCDDEEFF**"
      ..timestamp = DateTime.now()
      ..footer = (EmbedFooterBuilder()..text = client.footerText);

    await ctx.respond(MessageBuilder.embed(embed));
  },
  hideOriginalResponse: false,
  checks: [],
);
