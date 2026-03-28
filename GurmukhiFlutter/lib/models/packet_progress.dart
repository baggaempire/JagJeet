class PacketProgress {
  PacketProgress({required this.completedIds, required this.currentIndex});

  final Set<String> completedIds;
  final int currentIndex;

  static PacketProgress defaults() {
    return PacketProgress(completedIds: <String>{}, currentIndex: 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'completedIds': completedIds.toList(),
      'currentIndex': currentIndex,
    };
  }

  factory PacketProgress.fromJson(Map<String, dynamic> json) {
    return PacketProgress(
      completedIds: ((json['completedIds'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toSet()),
      currentIndex: (json['currentIndex'] as int?) ?? 0,
    );
  }
}
