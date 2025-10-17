import 'package:test_flutter/data/models/quran/progres_quran.dart';

enum QuranStatus { initial, loading, loaded, error, success, refreshing }

class QuranState {
  final QuranStatus status;
  final ProgresBacaQuran? progresBacaQuran;
  final String? message;

  const QuranState({required this.status, this.progresBacaQuran, this.message});

  factory QuranState.initial() {
    return const QuranState(
      status: QuranStatus.initial,
      progresBacaQuran: null,
      message: null,
    );
  }

  QuranState copyWith({
    QuranStatus? status,
    ProgresBacaQuran? progresBacaQuran,
    String? message,
  }) {
    return QuranState(
      status: status ?? this.status,
      progresBacaQuran: progresBacaQuran ?? this.progresBacaQuran,
      message: message ?? this.message,
    );
  }
}
