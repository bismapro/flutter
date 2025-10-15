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
  final ProgresPuasaWajibTahunIni? progresPuasaWajibTahunIni;
  final List<RiwayatPuasaWajib>? riwayatPuasaWajib;
  final String? message;
  final bool isOffline;

  PuasaState({
    required this.status,
    this.progresPuasaWajibTahunIni,
    this.message,
    this.riwayatPuasaWajib,
    required this.isOffline,
  });

  factory PuasaState.initial() {
    return PuasaState(
      status: PuasaStatus.initial,
      progresPuasaWajibTahunIni: null,
      riwayatPuasaWajib: [],
      message: null,
      isOffline: false,
    );
  }

  PuasaState copyWith({
    PuasaStatus? status,
    ProgresPuasaWajibTahunIni? progresPuasaWajibTahunIni,
    List<RiwayatPuasaWajib>? riwayatPuasaWajib,
    String? message,
    bool? isOffline,
  }) {
    return PuasaState(
      status: status ?? this.status,
      progresPuasaWajibTahunIni:
          progresPuasaWajibTahunIni ?? this.progresPuasaWajibTahunIni,
      riwayatPuasaWajib: riwayatPuasaWajib ?? this.riwayatPuasaWajib,
      message: message ?? this.message,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
