// File: features/profile/profile_state.dart

import 'package:test_flutter/data/models/user/user.dart'; // Impor model User

/// Enum untuk semua kemungkinan status UI profil.
enum ProfileStatus { initial, loading, loaded, error, success }

/// Class yang membungkus semua data yang dibutuhkan oleh UI Profil.
class ProfileState {
  final ProfileStatus status;
  final User? profile;
  final String? message;

  const ProfileState({required this.status, this.profile, this.message});

  /// State awal saat provider pertama kali dibuat.
  factory ProfileState.initial() {
    return ProfileState(
      status: ProfileStatus.initial,
      profile: null, // Awalnya null sampai di-load dari storage
      message: null,
    );
  }

  /// Helper method untuk membuat salinan state dengan perubahan.
  ProfileState copyWith({
    ProfileStatus? status,
    User? profile,
    String? message,
    bool? clearMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      message: clearMessage == true ? null : (message ?? this.message),
    );
  }
}
