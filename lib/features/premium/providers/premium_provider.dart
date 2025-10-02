import 'package:flutter/foundation.dart';
import 'package:test_flutter/core/utils/logger.dart';
import '../models/child_data.dart';

/// Provider untuk mengelola state premium dashboard
class PremiumProvider extends ChangeNotifier {
  // List anak-anak dalam keluarga
  List<ChildData> _children = [
    const ChildData(
      name: 'Ahmad',
      avatarUrl: '👦',
      prayerStreak: 15,
      quranProgress: 65,
      totalBadges: 12,
      prayedToday: true,
    ),
    const ChildData(
      name: 'Fatimah',
      avatarUrl: '👧',
      prayerStreak: 22,
      quranProgress: 80,
      totalBadges: 18,
      prayedToday: true,
    ),
  ];

  // Loading state
  bool _isLoading = false;

  // Getters
  List<ChildData> get children => List.unmodifiable(_children);
  bool get isLoading => _isLoading;
  int get totalChildren => _children.length;

  /// Calculate average badges for summary
  int get averageBadges {
    if (_children.isEmpty) return 0;
    return (_children.map((c) => c.totalBadges).reduce((a, b) => a + b) /
            _children.length)
        .round();
  }

  /// Calculate prayer completion percentage
  double get prayerCompletionRate {
    if (_children.isEmpty) return 0.0;
    final completedCount = _children.where((c) => c.prayedToday).length;
    return completedCount / _children.length;
  }

  /// Get total badges count
  int get totalBadges {
    if (_children.isEmpty) return 0;
    return _children.map((c) => c.totalBadges).reduce((a, b) => a + b);
  }

  /// Add new child
  Future<void> addChild(ChildData child) async {
    _setLoading(true);

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      _children.add(child);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.fine('Error adding child: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove child
  Future<void> removeChild(String childName) async {
    _setLoading(true);

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));

      _children.removeWhere((child) => child.name == childName);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.fine('Error removing child: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update child data
  Future<void> updateChild(String childName, ChildData updatedChild) async {
    _setLoading(true);

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _children.indexWhere((child) => child.name == childName);
      if (index != -1) {
        _children[index] = updatedChild;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        logger.fine('Error updating child: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Send reward to child (mock implementation)
  Future<void> sendReward(String childName, String message) async {
    _setLoading(true);

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // In real implementation, this would send notification to child
      if (kDebugMode) {
        logger.fine('Reward sent to $childName: $message');
      }

      // Could update badge count here
      final childIndex = _children.indexWhere(
        (child) => child.name == childName,
      );
      if (childIndex != -1) {
        final child = _children[childIndex];
        _children[childIndex] = child.copyWith(
          totalBadges: child.totalBadges + 1,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        logger.fine('Error sending reward: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh data
  Future<void> refreshData() async {
    _setLoading(true);

    try {
      // Simulate API call to refresh data
      await Future.delayed(const Duration(milliseconds: 1000));

      // In real implementation, this would fetch fresh data from API
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.fine('Error refreshing data: $e');
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Reset all data (for testing purposes)
  void resetData() {
    _children = [
      const ChildData(
        name: 'Ahmad',
        avatarUrl: '👦',
        prayerStreak: 15,
        quranProgress: 65,
        totalBadges: 12,
        prayedToday: true,
      ),
      const ChildData(
        name: 'Fatimah',
        avatarUrl: '👧',
        prayerStreak: 22,
        quranProgress: 80,
        totalBadges: 18,
        prayedToday: true,
      ),
    ];
    _isLoading = false;
    notifyListeners();
  }
}
