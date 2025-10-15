import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'connection_state.dart';

class ConnectionNotifier extends StateNotifier<ConnectionStateX> {
  ConnectionNotifier() : super(ConnectionStateX.initial) {
    _init();
  }

  StreamSubscription<List<ConnectivityResult>>? _connSub;
  StreamSubscription<InternetConnectionStatus>? _internetSub;

  Future<void> _init() async {
    // 1) Ambil tipe jaringan AKTIF (bisa lebih dari satu)
    final List<ConnectivityResult> types = await Connectivity()
        .checkConnectivity();

    // 2) Cek koneksi internet "beneran"
    final bool online = await InternetConnectionChecker.instance.hasConnection;

    state = state.copyWith(netTypes: types, isOnline: online);

    // 3) Listen perubahan tipe jaringan (List<ConnectivityResult>)
    _connSub = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) async {
      final bool onlineNow =
          await InternetConnectionChecker.instance.hasConnection;
      state = state.copyWith(netTypes: results, isOnline: onlineNow);
    });

    // 4) Listen perubahan status internet (connected/disconnected)
    _internetSub = InternetConnectionChecker.instance.onStatusChange.listen((
      status,
    ) {
      final bool onlineNow = status == InternetConnectionStatus.connected;
      if (state.isOnline != onlineNow) {
        state = state.copyWith(isOnline: onlineNow);
      }
    });
  }

  Future<void> refresh() async {
    final List<ConnectivityResult> types = await Connectivity()
        .checkConnectivity();
    final bool online = await InternetConnectionChecker.instance.hasConnection;
    state = state.copyWith(netTypes: types, isOnline: online);
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _internetSub?.cancel();
    super.dispose();
  }
}

final connectionProvider =
    StateNotifierProvider<ConnectionNotifier, ConnectionStateX>(
      (ref) => ConnectionNotifier(),
    );
