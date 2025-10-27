import 'package:test_flutter/data/models/progres_puasa/progres_puasa.dart';

enum PuasaStatus {
  initial,
  loading,
  loaded,
  error,
  success,
  refreshing,
  offline,
}

class PuasaState {
  final PuasaStatus status;
  // final ProgresPuasaWajibTahunIni? progresPuasaWajibTahunIni;
  final List<RiwayatPuasaWajib>? riwayatPuasaWajib;
  // final ProgresPuasaSunnahTahunIni? progresPuasaSunnahTahunIni;
  final RiwayatPuasaSunnah? riwayatPuasaSunnah;
  final String? message;
  final bool isOffline;

  PuasaState({
    required this.status,
    // this.progresPuasaWajibTahunIni,
    this.riwayatPuasaWajib,
    // this.progresPuasaSunnahTahunIni,
    this.riwayatPuasaSunnah,
    this.message,
    required this.isOffline,
  });

  factory PuasaState.initial() {
    return PuasaState(
      status: PuasaStatus.initial,
      // progresPuasaWajibTahunIni: null,
      riwayatPuasaWajib: [],
      // progresPuasaSunnahTahunIni: null,
      riwayatPuasaSunnah: null,
      message: null,
      isOffline: false,
    );
  }

  PuasaState copyWith({
    PuasaStatus? status,
    // // ProgresPuasaWajibTahunIni? progresPuasaWajibTahunIni,
    List<RiwayatPuasaWajib>? riwayatPuasaWajib,
    // // ProgresPuasaSunnahTahunIni? progresPuasaSunnahTahunIni,
    RiwayatPuasaSunnah? riwayatPuasaSunnah,
    String? message,
    bool? isOffline,
  }) {
    return PuasaState(
      status: status ?? this.status,
      // progresPuasaWajibTahunIni:
      // // progresPuasaWajibTahunIni ?? this.progresPuasaWajibTahunIni,
      riwayatPuasaWajib: riwayatPuasaWajib ?? this.riwayatPuasaWajib,
      // progresPuasaSunnahTahunIni:
      // // progresPuasaSunnahTahunIni ?? this.progresPuasaSunnahTahunIni,
      riwayatPuasaSunnah: riwayatPuasaSunnah ?? this.riwayatPuasaSunnah,
      message: message ?? this.message,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
