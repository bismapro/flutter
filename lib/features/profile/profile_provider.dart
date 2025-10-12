import 'package:flutter_riverpod/legacy.dart';
import 'package:test_flutter/core/utils/storage_helper.dart';
import 'package:test_flutter/data/models/user/user.dart';
import 'package:test_flutter/features/profile/profile_service.dart';
import 'package:test_flutter/features/profile/profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState.initial());

  /// Memuat data user dari local storage saat aplikasi dimulai.
  Future<void> loadUser() async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      // StorageHelper.getUser() sekarang kita asumsikan mengembalikan User
      final user = await StorageHelper.getUser();
      if (user != null) {
        final parseUser = User.fromJson(user);
        state = state.copyWith(
          status: ProfileStatus.loaded,
          profile: parseUser,
        );
      } else {
        throw Exception('Tidak ada data pengguna di storage');
      }
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        message: e.toString(),
      );
    }
  }

  /// Memperbarui profil pengguna (nama, email, telepon).
  Future<void> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final response = await ProfileService.updateProfile(name, email, phone);
      final updatedUser = User.fromJson(response.data);

      // Simpan user yang sudah diperbarui ke local storage
      await StorageHelper.saveUser(updatedUser as Map<String, dynamic>);

      state = state.copyWith(
        status: ProfileStatus.success,
        profile: updatedUser,
        message: response.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        message: e.toString(),
      );
    }
  }

  /// Memperbarui password pengguna.
  Future<void> editPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: ProfileStatus.loading);
    try {
      final response = await ProfileService.updatePassword(
        currentPassword,
        newPassword,
        confirmPassword,
      );

      state = state.copyWith(
        status: ProfileStatus.success,
        message: response.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: ProfileStatus.error,
        message: e.toString(),
      );
    }
  }

  /// Membersihkan pesan (error/sukses) setelah ditampilkan di UI.
  void clearMessage() {
    state = state.copyWith(clearMessage: true);
  }

  /// Mengembalikan status ke loaded setelah operasi sukses.
  void resetStatus() {
    if (state.status == ProfileStatus.success) {
      state = state.copyWith(status: ProfileStatus.loaded);
    }
  }
}

// Provider that can be used throughout the app
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((
  ref,
) {
  return ProfileNotifier();
});
