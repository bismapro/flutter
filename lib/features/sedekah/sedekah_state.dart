import 'package:test_flutter/data/models/sedekah/sedekah.dart';

enum SedekahStatus {
  initial,
  loading,
  loaded,
  error,
  success,
  refreshing,
  offline,
}

class SedekahState {
  final SedekahStatus status;
  final StatistikSedekah? sedekahStats;
  final String? message;
  final bool isOffline;

  const SedekahState({
    required this.status,
    this.sedekahStats,
    this.message,
    required this.isOffline,
  });

  factory SedekahState.initial() {
    return SedekahState(
      status: SedekahStatus.initial,
      sedekahStats: StatistikSedekah.empty(),
      isOffline: false,
      message: null,
    );
  }

  SedekahState copyWith({
    SedekahStatus? status,
    StatistikSedekah? sedekahStats,
    String? message,
    bool? isOffline,
    bool? clearMessage,
  }) {
    return SedekahState(
      status: status ?? this.status,
      sedekahStats: sedekahStats ?? this.sedekahStats,
      message: clearMessage == true ? null : (message ?? this.message),
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
