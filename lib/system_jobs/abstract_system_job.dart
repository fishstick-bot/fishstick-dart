import "package:nyxx/nyxx.dart";
import "../client/client.dart";
import "../database/database_user.dart";

/// User System Job Abstract Class
abstract class AbstractUserSystemJob {
  /// main client
  late final Client client;

  /// is the task running
  bool _isRunning = false;

  /// The task's name
  String name;

  /// Delay per user
  Duration delay;

  /// List of users to perform task on
  late List<DatabaseUser> users;

  /// Constructor
  AbstractUserSystemJob(this.client, {required this.name, required this.delay});

  /// toJson method
  Map<String, dynamic> toJson() => {
        "name": name,
        "delay": delay.inMilliseconds,
        "users": users.map((user) => user.id).toList(),
      };

  /// is the task running
  bool get running => _isRunning;

  /// set the task running or not
  set running(bool value) {
    if (value == _isRunning) return;
    _isRunning = value;
  }

  /// fetch the users
  Future<List<DatabaseUser>> fetchUsers() async {
    throw UnimplementedError();
  }

  /// run the task
  Future<void> run() async {
    if (_isRunning) {
      return;
    }

    running = true;

    int time = DateTime.now().millisecondsSinceEpoch;
    client.logger.info("[TASK:$name] starting...");

    try {
      await fetchUsers();

      for (final user in users) {
        await performOnUser(user);
      }
    } catch (e) {
      client.logger.shout("[TASK:$name] Unhandled error: $e");
    }

    client.logger.info(
        "[TASK:$name] finished in ${DateTime.now().millisecondsSinceEpoch - time}ms");
    running = false;
  }

  /// perform the task per user
  Future<dynamic> performOnUser(DatabaseUser user) async {
    throw UnimplementedError(
        "method performOnUser needs to be overrided in child task.");
  }

  /// send logs to a user
  Future<void> sendUserLog(DatabaseUser user, MessageBuilder builder) async {
    try {
      final IUser target = await client.bot.fetchUser(user.id.toSnowflake());
      await target.sendMessage(builder);
    } catch (e) {
      client.logger
          .shout("[TASK:$name:${user.id}] Failed to send user log: $e");
    }
  }
}
