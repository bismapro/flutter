import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/models/komunitas/komunitas.dart';
import 'package:test_flutter/data/models/paginated.dart';
import 'package:test_flutter/features/komunitas/services/komunitas_cache_service.dart';
import 'package:test_flutter/features/komunitas/services/komunitas_service.dart';

enum KomunitasArtikelState {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
  offline,
  refreshing,
  success,
}

class KomunitasArtikelNotifier extends StateNotifier<Map<String, dynamic>> {
  KomunitasArtikelNotifier()
    : super({
        'status': KomunitasArtikelState.initial,
        'artikel': <KomunitasArtikel>[],
        'currentPage': 1,
        'lastPage': 1,
        'error': null,
        'isOffline': false,
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

      // Try to load from network first
      try {
        final resp = await KomunitasService.getAllArtikel(page: page);
        logger.fine('Get all artikel response: $resp');

        final paginated = PaginatedResponse<KomunitasArtikel>.fromJson(
          resp,
          (json) => KomunitasArtikel.fromJson(json),
        );

        final List<KomunitasArtikel> existing = loadMore
            ? (state['artikel'] as List<KomunitasArtikel>)
            : <KomunitasArtikel>[];

        // Cache the data using specific cache service
        await KomunitasCacheService.cacheArtikel(
          artikel: paginated.data,
          currentPage: paginated.currentPage,
          totalPages: paginated.lastPage,
          totalItems: paginated.total,
          isLoadMore: loadMore,
        );

        state = {
          'status': KomunitasArtikelState.loaded,
          'artikel': [...existing, ...paginated.data],
          'currentPage': paginated.currentPage,
          'lastPage': paginated.lastPage,
          'error': null,
          'isOffline': false,
        };

        logger.fine(
          'Successfully loaded ${paginated.data.length} articles from network. ' +
              'Total: ${(state['artikel'] as List).length}, ' +
              'Current page: ${paginated.currentPage}, ' +
              'Last page: ${paginated.lastPage}',
        );
      } catch (networkError) {
        logger.warning(
          'Network error, trying to load from cache: $networkError',
        );

        if (!loadMore) {
          await _loadFromCache();
        } else {
          state = {
            ...state,
            'status': KomunitasArtikelState.loaded,
            'error':
                'Tidak dapat memuat lebih banyak artikel. Periksa koneksi internet.',
            'isOffline': true,
          };
        }
      }
    } catch (e) {
      logger.warning('Error load artikel: $e');

      if (loadMore) {
        state = {
          ...state,
          'status': KomunitasArtikelState.loaded,
          'error': 'Failed to load more articles: ${e.toString()}',
        };
      } else {
        await _loadFromCache();
      }
    }
  }

  Future<void> _loadFromCache() async {
    try {
      if (KomunitasCacheService.hasCachedArtikel()) {
        final cachedArtikel = KomunitasCacheService.getCachedArtikel();
        final metadata = KomunitasCacheService.getCacheMetadata();

        if (cachedArtikel.isNotEmpty) {
          state = {
            'status': KomunitasArtikelState.offline,
            'artikel': cachedArtikel,
            'currentPage': metadata?.currentPage ?? 1,
            'lastPage': metadata?.totalPages ?? 1,
            'error': KomunitasCacheService.isCacheValid()
                ? null
                : 'Data mungkin tidak terbaru. Tidak ada koneksi internet.',
            'isOffline': true,
          };

          logger.fine(
            'Loaded ${cachedArtikel.length} articles from cache. ' +
                'Cache valid: ${KomunitasCacheService.isCacheValid()}',
          );
          return;
        }
      }

      state = {
        ...state,
        'status': KomunitasArtikelState.error,
        'error': 'Tidak ada koneksi internet',
        'isOffline': true,
      };
    } catch (e) {
      logger.warning('Error loading from cache: $e');
      state = {
        ...state,
        'status': KomunitasArtikelState.error,
        'error': 'Gagal memuat data: ${e.toString()}',
        'isOffline': true,
      };
    }
  }

  Future<void> createArtikel({
    required String kategori,
    required String judul,
    required String isi,
    required List<XFile> gambar,
  }) async {
    state = {...state, 'status': KomunitasArtikelState.loading};
    try {
      final resp = await KomunitasService.createArtikel(
        kategori: kategori,
        judul: judul,
        isi: isi,
        gambar: gambar,
      );

      state = {...state, 'status': KomunitasArtikelState.success};

      logger.fine('Create artikel successful: $resp');
      await refresh();
    } catch (e) {
      state = {
        ...state,
        'status': KomunitasArtikelState.error,
        'error': e.toString(),
      };
      logger.warning('Error creating artikel: $e');
      throw Exception('Failed to create artikel: ${e.toString()}');
    }
  }

  void clearError() {
    state = {...state, 'error': null};
  }

  void clearSuccess() {
    state = {...state, 'status': KomunitasArtikelState.initial};
  }

  // Perbaiki refresh method
  Future<void> refresh() async {
    try {
      // Set refreshing state untuk UI yang berbeda jika diperlukan
      state = {...state, 'status': KomunitasArtikelState.refreshing};

      logger.fine('Refreshing artikel data...');

      // Try network first
      try {
        final resp = await KomunitasService.getAllArtikel(page: 1);
        final paginated = PaginatedResponse<KomunitasArtikel>.fromJson(
          resp,
          (json) => KomunitasArtikel.fromJson(json),
        );

        // Cache fresh data (isLoadMore: false untuk replace cache)
        await KomunitasCacheService.cacheArtikel(
          artikel: paginated.data,
          currentPage: paginated.currentPage,
          totalPages: paginated.lastPage,
          totalItems: paginated.total,
          isLoadMore: false, // Important: false untuk replace cache
        );

        // Update state dengan data baru
        state = {
          'status': KomunitasArtikelState.loaded,
          'artikel': paginated.data, // Replace dengan data baru
          'currentPage': paginated.currentPage,
          'lastPage': paginated.lastPage,
          'error': null,
          'isOffline': false,
        };

        logger.fine(
          'Refresh successful: ${paginated.data.length} articles loaded',
        );
      } catch (networkError) {
        logger.warning('Refresh failed, keeping existing data: $networkError');

        // Jika gagal refresh, tetap gunakan data yang ada dan set offline
        if ((state['artikel'] as List).isNotEmpty) {
          state = {
            ...state,
            'status': KomunitasArtikelState.offline,
            'error': 'Gagal memperbarui data. Menampilkan data tersimpan.',
            'isOffline': true,
          };
        } else {
          // Jika tidak ada data sama sekali, coba load dari cache
          await _loadFromCache();
        }
      }
    } catch (e) {
      logger.warning('Refresh error: $e');

      // Fallback ke data yang ada atau cache
      if ((state['artikel'] as List).isEmpty) {
        await _loadFromCache();
      } else {
        state = {
          ...state,
          'status': KomunitasArtikelState.loaded,
          'error': 'Gagal memperbarui data: ${e.toString()}',
        };
      }
    }
  }

  bool get canLoadMore {
    final currentPage = state['currentPage'] as int;
    final lastPage = state['lastPage'] as int;
    final status = state['status'];
    final isOffline = state['isOffline'] as bool;

    return currentPage < lastPage &&
        status != KomunitasArtikelState.loading &&
        status != KomunitasArtikelState.loadingMore &&
        status != KomunitasArtikelState.refreshing && // Tambah check refreshing
        !isOffline;
  }

  bool get isOffline => state['isOffline'] as bool;

  Future<void> clearCache() async {
    await KomunitasCacheService.clearCache();
    logger.fine('Komunitas cache cleared manually');
  }

  Map<String, int> getCacheInfo() {
    return KomunitasCacheService.getCacheInfo();
  }
}

final komunitasProvider =
    StateNotifierProvider<KomunitasArtikelNotifier, Map<String, dynamic>>((
      ref,
    ) {
      return KomunitasArtikelNotifier();
    });
