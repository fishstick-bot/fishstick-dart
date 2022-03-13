class DatabaseTinyUrl {
  String code;
  DateTime created;
  String targetUrl;

  DatabaseTinyUrl(
    this.code, {
    required this.created,
    required this.targetUrl,
  });
}
