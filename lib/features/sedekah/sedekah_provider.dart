import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
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
  success,
}

class SedekahNotifier extends StateNotifier<Map<String, dynamic>> {
  SedekahNotifier()
    : super({
        'status': SedekahState.initial,
        'sedekahStats': null,
        'sedekah': <Sedekah>[],
        'response': null,
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

  Future<void> addSedekah(
    String jenisSedekah,
    String tanggal,
    int jumlah,
    String? keterangan,
  ) async {
    state = {...state, 'status': SedekahState.loading};

    try {
      final response = await SedekahService.addSedekah(
        jenisSedekah,
        tanggal,
        jumlah,
        keterangan,
      );

      state = {
        ...state,
        'status': SedekahState.success,
        'response': jsonEncode(response),
      };
    } catch (error) {
      state = {
        ...state,
        'status': SedekahState.error,
        'error': error.toString(),
      };
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
