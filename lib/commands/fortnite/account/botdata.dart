import "package:nyxx/nyxx.dart";
import "package:nyxx_commands/nyxx_commands.dart";
// import "package:fortnite/fortnite.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;
import "../../../database/database_user.dart";
import "../../../extensions/context_extensions.dart";
import "../../../utils/utils.dart";
import "../../../fishstick_dart.dart";

final Command botDataCommand = Command(
  "botdata",
  "Sends your saved data in bot in a pdf file.",
  (Context ctx) async {
    DatabaseUser user = await ctx.dbUser;
    user.fnClientSetup();

    final pdf = pw.Document(pageMode: PdfPageMode.outlines);

    pdf.addPage(
      pw.Page(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 1.5 * PdfPageFormat.cm,
          ),
          orientation: pw.PageOrientation.portrait,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Center(
                  child: pw.Text(
                    ctx.user.tag,
                    style: pw.Theme.of(context).header0,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  context: context,
                  data: [
                    ["Key", "Value"],
                    ["ID", ctx.user.id],
                    ["Selected Account", user.selectedAccount],
                    [
                      "Premium (Enum | Tier)",
                      "${user.premium.tierEnum} | ${user.premium.tier}"
                    ],
                    ["Premium Until", user.premium.until.toString()],
                    ["Premium Granted By", user.premium.grantedBy],
                    ["isPremium", user.isPremium],
                    ["isPartner", user.isPartner],
                    ["isBanned", user.isBanned],
                    ["isOwner", user.id == client.config.ownerId],
                    ["Epic Accounts Limit", user.accountsLimit],
                    ["Bonus Account Limit (deprecated)", user.bonusAccLimit],
                    ["Auto Daily", user.autoSubscriptions.dailyRewards],
                    ["Auto Free Llamas", user.autoSubscriptions.freeLlamas],
                    [
                      "Auto Research",
                      user.autoSubscriptions.collectResearchPoints
                    ],
                    ["DM Notifications", user.dmNotifications],
                    ["Color", user.color],
                    ["Mentions Privacy", user.privacyEnum],
                    ["Blacklisted", user.blacklisted.value],
                  ],
                ),
                pw.Padding(padding: const pw.EdgeInsets.all(10)),
                pw.Paragraph(text: "Don't share this file with anyone!"),
              ],
            );
          }),
    );

    pdf.addPage(
      pw.Page(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 1.5 * PdfPageFormat.cm,
          ),
          orientation: pw.PageOrientation.portrait,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Center(
                  child: pw.Text(
                    "Epic Accounts",
                    style: pw.Theme.of(context).header0,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(data: [
                  ["Epic Name", "Account ID", "Device ID", "Secret"],
                  ...user.linkedAccounts
                      .map((a) => [
                            a.displayName,
                            a.accountId,
                            a.deviceAuth.deviceId,
                            a.deviceAuth.secret
                          ])
                      .toList()
                ]),
                pw.Padding(padding: const pw.EdgeInsets.all(10)),
                pw.Paragraph(text: "Don't share this file with anyone!"),
              ],
            );
          }),
    );

    for (var acc in user.linkedAccounts) {
      pdf.addPage(
        pw.Page(
            pageFormat: PdfPageFormat.a4.copyWith(
              marginBottom: 1.5 * PdfPageFormat.cm,
            ),
            orientation: pw.PageOrientation.portrait,
            build: (pw.Context context) {
              return pw.Column(
                children: [
                  pw.Center(
                    child: pw.Text(
                      acc.displayName,
                      style: pw.Theme.of(context).header0,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Table.fromTextArray(data: [
                    ["Key", "Value"],
                    ["Display Name", acc.displayName],
                    ["Account ID", acc.accountId],
                    ["Device ID", acc.deviceAuth.deviceId],
                    ["Secret", acc.deviceAuth.secret],
                    ["Avatar", acc.avatar],
                    ["Power Level", acc.powerLevel],
                    ["Last Dailies Refresh", acc.dailiesLastRefresh],
                    ["Last Daily Reward Claim", acc.lastDailyRewardClaim],
                    ["Last Free Llamas Claim", acc.lastFreeLlamasClaim],
                    [
                      "Cached Research Values",
                      acc.cachedResearchValues.toJson().toString()
                    ],
                  ]),
                  pw.Padding(padding: const pw.EdgeInsets.all(10)),
                  pw.Paragraph(text: "Don't share this file with anyone!"),
                ],
              );
            }),
      );
    }

    return await ctx.respond(
      MessageBuilder.files(
          [AttachmentBuilder.bytes(await pdf.save(), "${ctx.user.id}.pdf")]),
      private: true,
    );
  },
  hideOriginalResponse: true,
  checks: [],
);
