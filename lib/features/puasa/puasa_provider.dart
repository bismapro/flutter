import 'package:flutter_riverpod/legacy.dart';
import 'package:test_flutter/data/models/progres_puasa/progres_puasa.dart';
import 'package:test_flutter/features/puasa/puasa_state.dart';
import 'package:test_flutter/features/puasa/services/puasa_service.dart';

class PuasaNotifier extends StateNotifier<PuasaState> {
  PuasaNotifier() : super(PuasaState.initial());

  // Init
  Future<void> init() async {
    await fetchProgresPuasaWajibTahunIni();
    await fetchRiwayatPuasaWajib();
  }

  // Fetch Progres Puasa Wajib Tahun Ini
  Future<void> fetchProgresPuasaWajibTahunIni() async {
    try {
      state = state.copyWith(status: PuasaStatus.loading, message: null);
      final result = await PuasaService.getProgresPuasaWajibTahunIni();

      final dataJson = result['data'] as Map<String, dynamic>?;

      final progres = (dataJson == null)
          ? null
          : ProgresPuasaWajibTahunIni.fromJson(dataJson);

      state = state.copyWith(
        status: PuasaStatus.loaded,
        progresPuasaWajibTahunIni: progres,
        message: result['message'],
      );
    } catch (e) {
      state = state.copyWith(status: PuasaStatus.error, message: e.toString());
    }
  }

  // Fetch Riwayat Puasa Wajib
  Future<void> fetchRiwayatPuasaWajib() async {
    try {
      state = state.copyWith(status: PuasaStatus.loading, message: null);
      final result = await PuasaService.getRiwayatPuasaWajib();
      final status = result['status'] as bool;
      final message = result['message'] as String;
      if (status) {
        final riwayat = result['data'] as List<RiwayatPuasaWajib>;
        state = state.copyWith(
          status: PuasaStatus.loaded,
          riwayatPuasaWajib: riwayat,
          message: message,
        );
      } else {
        state = state.copyWith(status: PuasaStatus.error, message: message);
      }
    } catch (e) {
      state = state.copyWith(status: PuasaStatus.error, message: e.toString());
    }
  }

  // Add Progres Puasa Wajib
  Future<void> addProgresPuasaWajib({required String tanggalRamadhan}) async {
    try {
      state = state.copyWith(status: PuasaStatus.loading, message: null);
      final result = await PuasaService.addProgresPuasaWajib(
        tanggalRamadhan: tanggalRamadhan,
      );
      final status = result['status'] as bool;
      final message = result['message'] as String;
      if (status) {
        state = state.copyWith(status: PuasaStatus.success, message: message);
        await fetchProgresPuasaWajibTahunIni();
        await fetchRiwayatPuasaWajib();
      } else {
        state = state.copyWith(status: PuasaStatus.error, message: message);
      }
    } catch (e) {
      state = state.copyWith(status: PuasaStatus.error, message: e.toString());
    }
  }

  // Delete Progres Puasa Wajib
  Future<void> deleteProgresPuasaWajib({required String id}) async {
    try {
      state = state.copyWith(status: PuasaStatus.loading, message: null);
      final result = await PuasaService.deleteProgresPuasaWajib(id: id);
      final status = result['status'] as bool;
      final message = result['message'] as String;
      if (status) {
        state = state.copyWith(status: PuasaStatus.success, message: message);
        await fetchProgresPuasaWajibTahunIni();
        await fetchRiwayatPuasaWajib();
      } else {
        state = state.copyWith(status: PuasaStatus.error, message: message);
      }
    } catch (e) {
      state = state.copyWith(status: PuasaStatus.error, message: e.toString());
    }
  }
}

final puasaProvider = StateNotifierProvider<PuasaNotifier, PuasaState>(
  (ref) => PuasaNotifier(),
);
