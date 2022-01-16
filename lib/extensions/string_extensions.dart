extension Util on String {
  String toBold() => "**$this**";
  String upperCaseFirst() => "${split("")[0].toUpperCase()}${substring(1)}";
}
