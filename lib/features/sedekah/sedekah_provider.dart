import 'package:flutter_riverpod/legacy.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/models/sedekah/sedekah.dart';
import 'package:test_flutter/features/sedekah/services/sedekah_cache_service.dart';
import 'package:test_flutter/features/sedekah/services/sedekah_service.dart';

enum SedekahState {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
  offline,
  refreshing,
}

class SedekahNotifier extends StateNotifier<Map<String, dynamic>> {
  SedekahNotifier()
    : super({
        'status': SedekahState.initial,
        'sedekahStats': null,
        'sedekah': <Sedekah>[],
        'error': null,
        'isOffline': false,
      });

  Future<void> loadSedekah() async {
    state = {...state, 'status': SedekahState.loading};

    try {
      final response = await SedekahService.loadStats();
      final sedekahStats = StatistikSedekah.fromJson(
        response,
      ); // Parse the response

      // Cache the stats
      await SedekahCacheService.cacheSedekahStats(stats: sedekahStats);

      logger.fine('Loaded sedekah stats', sedekahStats.toJson());

      state = {
        ...state,
        'status': SedekahState.loaded,
        'sedekahStats': sedekahStats,
      };
    } catch (networkError) {
      if (SedekahCacheService.hasCachedSedekahStats()) {
        final cached = SedekahCacheService.getCacheSedekahStats();
        state = {
          ...state,
          'status': SedekahState.offline,
          'sedekahStats': cached,
          'isOffline': true,
        };
      } else {
        state = {
          ...state,
          'status': SedekahState.error,
          'error': networkError.toString(),
        };
      }
    }
  }

  void clearError() {
    state = {...state, 'error': null};
  }

  void clearSuccess() {
    state = {...state, 'status': SedekahState.initial};
  }
}

final sedekahProvider =
    StateNotifierProvider<SedekahNotifier, Map<String, dynamic>>((ref) {
      return SedekahNotifier();
    });
