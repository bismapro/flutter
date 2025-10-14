import 'package:test_flutter/data/models/sholat/sholat.dart';

enum SholatStatus { initial, loading, loaded, error, refreshing, offline }

class SholatState {
  final SholatStatus status;
  final List<Sholat> sholatList;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? localDate;
  final String? localTime;
  final String? message;
  final bool isOffline;

  const SholatState({
    required this.status,
    required this.sholatList,
    this.latitude,
    this.longitude,
    this.locationName,
    this.localDate,
    this.localTime,
    this.message,
    required this.isOffline,
  });

  factory SholatState.initial() {
    return const SholatState(
      status: SholatStatus.initial,
      sholatList: [],
      isOffline: false,
    );
  }

  SholatState copyWith({
    SholatStatus? status,
    List<Sholat>? sholatList,
    double? latitude,
    double? longitude,
    String? locationName,
    String? localDate,
    String? localTime,
    String? message,
    bool? isOffline,
  }) {
    return SholatState(
      status: status ?? this.status,
      sholatList: sholatList ?? this.sholatList,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      localDate: localDate ?? this.localDate,
      localTime: localTime ?? this.localTime,
      message: message ?? this.message,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
