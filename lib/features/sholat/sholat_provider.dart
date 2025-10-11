import 'package:flutter_riverpod/legacy.dart';

enum SholatState { initial, loading, loaded, error }

class SholatProvider extends StateNotifier<SholatState> {
  SholatProvider() : super(SholatState.initial);
}
