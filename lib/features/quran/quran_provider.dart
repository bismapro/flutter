import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/data/models/quran/progres_quran.dart';
import 'package:test_flutter/features/quran/quran_state.dart';
import 'package:test_flutter/features/quran/services/quran_progres_service.dart';

class QuranNotifier extends StateNotifier<QuranState> {
  QuranNotifier() : super(QuranState.initial());

  // Init - Load from local storage first
  Future<void> init() async {
    try {
      logger.fine('🔄 Initializing Quran Provider...');

      final localProgress = await fetchProgresBacaTerakhirFromLocal();

      logger.fine(
        '📖 Local progress: Surah ${localProgress.suratId}, Ayah ${localProgress.ayat}',
      );

      if (localProgress.suratId > 0) {
        state = state.copyWith(
          status: QuranStatus.loaded,
          progresBacaQuran: localProgress,
        );
        logger.fine('✅ Loaded from local storage');
      } else {
        state = state.copyWith(
          status: QuranStatus.loaded,
          progresBacaQuran: null,
        );
        logger.fine('ℹ️ No local progress found');
      }

      // Try to sync with API in background
      try {
        await fetchTerakhirBaca();
      } catch (e) {
        logger.fine('⚠️ API sync failed, using local data: $e');
      }
    } catch (e) {
      logger.fine('❌ Init error: $e');
      state = state.copyWith(status: QuranStatus.error, message: e.toString());
    }
  }

  // Save Progres Baca Terakhir to Local Storage
  Future<void> saveProgresBacaTerakhirToLocal(ProgresBacaQuran progres) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(progres.toJson());
      await prefs.setString('progresBacaQuran', jsonString);
      logger.fine(
        '💾 Saved to local: Surah ${progres.suratId}, Ayah ${progres.ayat}',
      );
    } catch (e) {
      logger.fine('❌ Failed to save local: $e');
    }
  }

  // Fetch Progres Baca Terakhir from Local Storage
  Future<ProgresBacaQuran> fetchProgresBacaTerakhirFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('progresBacaQuran');

      if (jsonString == null || jsonString.isEmpty) {
        logger.fine('📭 No local progress found');
        return ProgresBacaQuran(
          id: 0,
          suratId: 0,
          ayat: 0,
          createdAt: '',
          userId: 0,
        );
      }

      final decode = jsonDecode(jsonString);
      final progres = ProgresBacaQuran.fromJson(decode);
      logger.fine(
        '📖 Local progress loaded: Surah ${progres.suratId}, Ayah ${progres.ayat}',
      );

      return progres;
    } catch (e) {
      logger.fine('❌ Error loading local progress: $e');
      return ProgresBacaQuran(
        id: 0,
        suratId: 0,
        ayat: 0,
        createdAt: '',
        userId: 0,
      );
    }
  }

  // Fetch Progres Terakhir Baca from API
  Future<void> fetchTerakhirBaca() async {
    try {
      logger.fine('🌐 Fetching progress from API...');

      state = state.copyWith(status: QuranStatus.loading, message: null);

      final result = await QuranProgresService.getProgresBacaTerakhir();

      logger.fine('📡 API Response: $result');

      final status = result['status'] as bool;
      final message = result['message'] as String;

      if (status) {
        final dataJson = result['data'];

        logger.fine('📦 Data from API: $dataJson');

        if (dataJson != null && dataJson is Map<String, dynamic>) {
          final progres = ProgresBacaQuran.fromJson(dataJson);

          logger.fine(
            '✅ Progress parsed: Surah ${progres.suratId}, Ayah ${progres.ayat}',
          );

          if (progres.suratId > 0) {
            // Save to local storage
            await saveProgresBacaTerakhirToLocal(progres);

            state = state.copyWith(
              status: QuranStatus.loaded,
              progresBacaQuran: progres,
              message: message,
            );

            logger.fine('✅ Progress updated successfully');
          } else {
            logger.fine('⚠️ Invalid progress data (suratId = 0)');
            // Keep local data if API returns invalid data
            final localProgress = await fetchProgresBacaTerakhirFromLocal();
            state = state.copyWith(
              status: QuranStatus.loaded,
              progresBacaQuran: localProgress.suratId > 0
                  ? localProgress
                  : null,
            );
          }
        } else {
          logger.fine('⚠️ No data in API response, using local');
          // No progress from API, use local
          final localProgress = await fetchProgresBacaTerakhirFromLocal();
          state = state.copyWith(
            status: QuranStatus.loaded,
            progresBacaQuran: localProgress.suratId > 0 ? localProgress : null,
          );
        }
      } else {
        logger.fine('❌ API returned error: $message');
        state = state.copyWith(status: QuranStatus.error, message: message);
      }
    } catch (e) {
      logger.fine('❌ API Error: $e');

      // On error, load from local storage
      final localProgress = await fetchProgresBacaTerakhirFromLocal();

      if (localProgress.suratId > 0) {
        state = state.copyWith(
          status: QuranStatus.loaded,
          progresBacaQuran: localProgress,
          message: 'Using cached data',
        );
        logger.fine(
          '📱 Fallback to local: Surah ${localProgress.suratId}, Ayah ${localProgress.ayat}',
        );
      } else {
        state = state.copyWith(
          status: QuranStatus.error,
          message: 'Failed to load progress: ${e.toString()}',
        );
      }
    }
  }

  // Add Progres Quran
  Future<void> addProgresQuran({
    required String suratId,
    required String ayat,
  }) async {
    try {
      logger.fine('💾 Saving progress: Surah $suratId, Ayah $ayat');

      state = state.copyWith(status: QuranStatus.loading, message: null);

      final result = await QuranProgresService.addProgresQuran(
        suratId: suratId,
        ayat: ayat,
      );

      logger.fine('📡 Save response: $result');

      final status = result['status'];
      final message = result['message'];

      if (status) {
        logger.fine('✅ Progress saved to API');

        // Create progress object for local storage
        final progres = ProgresBacaQuran(
          id: result['data']?['id'] ?? DateTime.now().millisecondsSinceEpoch,
          suratId: int.parse(suratId),
          ayat: int.parse(ayat),
          createdAt:
              result['data']?['created_at'] ?? DateTime.now().toIso8601String(),
          userId: result['data']?['user_id'] ?? 0,
        );

        // Save to local
        await saveProgresBacaTerakhirToLocal(progres);

        state = state.copyWith(
          status: QuranStatus.success,
          message: message,
          progresBacaQuran: progres,
        );

        logger.fine('✅ Progress saved locally and updated state');

        // Fetch latest from API
        await fetchTerakhirBaca();
      } else {
        logger.fine('❌ API save failed: $message');
        state = state.copyWith(status: QuranStatus.error, message: message);
      }
    } catch (e) {
      logger.fine('❌ Save error: $e');

      // If offline, save to local only
      final localProgress = ProgresBacaQuran(
        id: DateTime.now().millisecondsSinceEpoch,
        suratId: int.parse(suratId),
        ayat: int.parse(ayat),
        createdAt: DateTime.now().toIso8601String(),
        userId: 0,
      );

      await saveProgresBacaTerakhirToLocal(localProgress);

      state = state.copyWith(
        status: QuranStatus.loaded,
        progresBacaQuran: localProgress,
        message: 'Saved locally (offline)',
      );

      logger.fine('💾 Saved offline: Surah $suratId, Ayah $ayat');
    }
  }
}

final quranProvider = StateNotifierProvider<QuranNotifier, QuranState>(
  (ref) => QuranNotifier(),
);
