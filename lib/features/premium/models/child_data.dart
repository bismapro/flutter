/// Model untuk data anak dalam family dashboard
class ChildData {
  final String name;
  final String avatarUrl;
  final int prayerStreak;
  final int quranProgress;
  final int totalBadges;
  final bool prayedToday;

  const ChildData({
    required this.name,
    required this.avatarUrl,
    required this.prayerStreak,
    required this.quranProgress,
    required this.totalBadges,
    required this.prayedToday,
  });

  /// Create a copy of this ChildData with some fields replaced
  ChildData copyWith({
    String? name,
    String? avatarUrl,
    int? prayerStreak,
    int? quranProgress,
    int? totalBadges,
    bool? prayedToday,
  }) {
    return ChildData(
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      prayerStreak: prayerStreak ?? this.prayerStreak,
      quranProgress: quranProgress ?? this.quranProgress,
      totalBadges: totalBadges ?? this.totalBadges,
      prayedToday: prayedToday ?? this.prayedToday,
    );
  }

  /// Convert to Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
      'prayerStreak': prayerStreak,
      'quranProgress': quranProgress,
      'totalBadges': totalBadges,
      'prayedToday': prayedToday,
    };
  }

  /// Create from Map for JSON deserialization
  factory ChildData.fromJson(Map<String, dynamic> json) {
    return ChildData(
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      prayerStreak: json['prayerStreak'] as int,
      quranProgress: json['quranProgress'] as int,
      totalBadges: json['totalBadges'] as int,
      prayedToday: json['prayedToday'] as bool,
    );
  }

  @override
  String toString() {
    return 'ChildData(name: $name, avatarUrl: $avatarUrl, prayerStreak: $prayerStreak, quranProgress: $quranProgress, totalBadges: $totalBadges, prayedToday: $prayedToday)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChildData &&
        other.name == name &&
        other.avatarUrl == avatarUrl &&
        other.prayerStreak == prayerStreak &&
        other.quranProgress == quranProgress &&
        other.totalBadges == totalBadges &&
        other.prayedToday == prayedToday;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        avatarUrl.hashCode ^
        prayerStreak.hashCode ^
        quranProgress.hashCode ^
        totalBadges.hashCode ^
        prayedToday.hashCode;
  }
}
