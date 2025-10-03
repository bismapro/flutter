import 'package:flutter_riverpod/legacy.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/models/komunitas_artikel.dart';
import 'package:test_flutter/data/models/paginated.dart';
import 'package:test_flutter/features/komunitas/komunitas_service.dart';

enum KomunitasArtikelState { initial, loading, loaded, error, loadingMore }

class KomunitasArtikelNotifier extends StateNotifier<Map<String, dynamic>> {
  KomunitasArtikelNotifier()
    : super({
        'status': KomunitasArtikelState.initial,
        'artikel': <KomunitasArtikel>[],
        'currentPage': 1,
        'lastPage': 1,
        'error': null,
      });

  Future<void> loadArtikel({bool loadMore = false}) async {
    try {
      // Set appropriate loading state
      if (loadMore) {
        state = {...state, 'status': KomunitasArtikelState.loadingMore};
      } else {
        state = {...state, 'status': KomunitasArtikelState.loading};
      }

      int page = loadMore ? (state['currentPage'] as int) + 1 : 1;

      logger.fine('Loading artikel page: $page, loadMore: $loadMore');

      final resp = await KomunitasService.getAllArtikel(page: page);
      logger.fine('Get all artikel response: $resp');

      final paginated = PaginatedResponse<KomunitasArtikel>.fromJson(
        resp,
        (json) => KomunitasArtikel.fromJson(json),
      );

      final List<KomunitasArtikel> existing = loadMore
          ? (state['artikel'] as List<KomunitasArtikel>)
          : <KomunitasArtikel>[];

      state = {
        'status': KomunitasArtikelState.loaded,
        'artikel': [...existing, ...paginated.data],
        'currentPage': paginated.currentPage,
        'lastPage': paginated.lastPage,
        'error': null,
      };

      logger.fine(
        'Successfully loaded ${paginated.data.length} articles. ' +
            'Total: ${(state['artikel'] as List).length}, ' +
            'Current page: ${paginated.currentPage}, ' +
            'Last page: ${paginated.lastPage}',
      );
    } catch (e) {
      logger.warning('Error load artikel: $e');

      // If it's load more error, keep existing data
      if (loadMore) {
        state = {
          ...state,
          'status': KomunitasArtikelState.loaded,
          'error': 'Failed to load more articles: ${e.toString()}',
        };
      } else {
        state = {
          ...state,
          'status': KomunitasArtikelState.error,
          'error': e.toString(),
        };
      }
    }
  }

  void clearError() {
    state = {...state, 'error': null};
  }

  // Method to refresh data (pull to refresh)
  Future<void> refresh() async {
    await loadArtikel(loadMore: false);
  }

  // Method to check if can load more
  bool get canLoadMore {
    final currentPage = state['currentPage'] as int;
    final lastPage = state['lastPage'] as int;
    final status = state['status'];

    return currentPage < lastPage &&
        status != KomunitasArtikelState.loading &&
        status != KomunitasArtikelState.loadingMore;
  }
}

final komunitasProvider =
    StateNotifierProvider<KomunitasArtikelNotifier, Map<String, dynamic>>((
      ref,
    ) {
      return KomunitasArtikelNotifier();
    });
