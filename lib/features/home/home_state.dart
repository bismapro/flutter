import 'package:test_flutter/data/models/komunitas/komunitas.dart';
import 'package:test_flutter/data/models/sholat/sholat.dart';

enum HomeStatus { initial, loading, loaded, error, refreshing, offline }

class HomeState {
  final HomeStatus status;
  final Sholat? jadwalSholat;
  final List<KomunitasPostingan> articles;
  final String? error;
  final String? locationError;
  final Map<String, dynamic>? lastLocation;
  final bool isOffline;

  const HomeState({
    required this.status,
    this.jadwalSholat,
    this.articles = const [],
    this.error,
    this.locationError,
    this.lastLocation,
    this.isOffline = false,
  });

  factory HomeState.initial() {
    return const HomeState(
      status: HomeStatus.initial,
      articles: [],
      isOffline: false,
    );
  }

  HomeState copyWith({
    HomeStatus? status,
    Sholat? jadwalSholat,
    List<KomunitasPostingan>? articles,
    String? error,
    String? locationError,
    Map<String, dynamic>? lastLocation,
    bool? isOffline,
    bool clearError = false,
    bool clearLocationError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      jadwalSholat: jadwalSholat ?? this.jadwalSholat,
      articles: articles ?? this.articles,
      error: clearError ? null : (error ?? this.error),
      locationError: clearLocationError
          ? null
          : (locationError ?? this.locationError),
      lastLocation: lastLocation ?? this.lastLocation,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
