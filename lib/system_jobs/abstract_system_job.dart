import "package:nyxx/nyxx.dart";
import "../fishstick_dart.dart";
import "../database/database_user.dart";

/// User System Job Abstract Class
abstract class AbstractUserSystemJob {
  /// is the task running
  bool _isRunning = false;

  /// The task's name
  String name;

  /// Delay per user
  Duration delay;

  /// Number of users to do at once
  int threads;

  /// List of users to perform task on
  late List<DatabaseUser> users;

  /// Constructor
  AbstractUserSystemJob({
    required this.name,
    required this.delay,
    this.threads = 1,
  });

  /// toJson method
  Map<String, dynamic> toJson() => {
        "name": name,
        "delay": delay.inMilliseconds,
        "threads": threads,
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

    try {
      for (int i = 0; i < users.length; i += threads) {
        await Future.wait((users.sublist(
                i, ((i + threads > users.length) ? users.length : i + threads)))
            .map(performOnUser));
      }
    } catch (e) {
      client.logger.shout("[TASK:$name] Unhandled error: $e");
    }

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
          .shout("[TASK:$name] Failed to send user log for ${user.id}: $e");
    }
  }
}
