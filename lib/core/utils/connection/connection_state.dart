import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionStateX {
  final bool isOnline; // hasil cek internet sungguhan
  final List<ConnectivityResult> netTypes; // bisa Wi-Fi + VPN sekaligus, dll.

  const ConnectionStateX({required this.isOnline, required this.netTypes});

  ConnectionStateX copyWith({
    bool? isOnline,
    List<ConnectivityResult>? netTypes,
  }) {
    return ConnectionStateX(
      isOnline: isOnline ?? this.isOnline,
      netTypes: netTypes ?? this.netTypes,
    );
  }

  static const initial = ConnectionStateX(
    isOnline: false,
    netTypes: <ConnectivityResult>[ConnectivityResult.none],
  );
}
