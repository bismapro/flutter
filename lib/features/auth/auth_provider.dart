import 'package:flutter_riverpod/legacy.dart';
import 'package:test_flutter/core/utils/logger.dart';
import 'package:test_flutter/core/utils/storage_helper.dart';
import 'package:test_flutter/features/auth/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  isRegistered,
}

class AuthStateNotifier extends StateNotifier<Map<String, dynamic>> {
  AuthStateNotifier()
    : super({'status': AuthState.initial, 'user': null, 'error': null});

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    state = {...state, 'status': AuthState.loading};
    logger.fine('Checking auth status...');

    try {
      // Coba ambil user dari server
      final response = await AuthService.getCurrentUser();
      final data = response['data'];

      if (data != null) {
        // Kalau sukses ambil dari server
        state = {
          'status': AuthState.authenticated,
          'user': data,
          'error': null,
        };

        // Sync ulang user ke storage biar up-to-date
        await StorageHelper.saveUser(data);
      } else {
        state = {
          'status': AuthState.unauthenticated,
          'user': null,
          'error': null,
        };
      }
    } catch (e) {
      logger.warning('Tidak ada internet, coba pakai local storage...');

      // Kalau gagal (offline), cek apakah ada data user di storage
      final localUser = await StorageHelper.getUser();
      final localToken = await StorageHelper.getToken();

      if (localUser != null && localToken != null) {
        // Anggap masih authenticated (offline mode)
        state = {
          'status': AuthState.authenticated,
          'user': localUser,
          'error': null,
        };
      } else {
        // Tidak ada data local, berarti belum login
        state = {
          'status': AuthState.unauthenticated,
          'user': null,
          'error': 'Offline dan tidak ada data user',
        };
      }
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    try {
      state = {...state, 'status': AuthState.loading, 'error': null};
      // Call API
      final response = await AuthService.login(email, password);

      final data = response['data'];
      logger.fine('Login response: $data');

      if (data == null) {
        throw Exception('Invalid response from server');
      }

      // Save token first
      if (data['access_token'] != null) {
        await StorageHelper.saveToken(data['access_token']);
        logger.fine('Token saved: ${data['access_token']}');
      } else {
        throw Exception('No token received from server');
      }

      // Save user data
      if (data['user'] != null) {
        final user = data['user'];

        await StorageHelper.saveUser({
          "id": user['id'].toString(),
          "name": user['name'].toString(),
          "email": user['email'].toString(),
          "role": user['role'].toString(),
        });

        logger.fine(
          'User data saved - ID: ${user['id']}, Name: ${user['name']}, Email: ${user['email']}, Role: ${user['role']}',
        );
      }

      // Update state to authenticated
      state = {
        'status': AuthState.authenticated,
        'user': data['user'],
        'error': null,
      };

      logger.fine('Authentication state set to authenticated');
    } catch (e) {
      logger.fine('Login error: ${e.toString()}');
      // Extract error message from Exception
      String errorMessage;
      if (e is Exception) {
        // Get clean error message without 'Exception: ' prefix
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      // Update state with formatted error
      state = {'status': AuthState.error, 'user': null, 'error': errorMessage};
    }
  }

  // Register
  Future<void> register(
    String name,
    String email,
    String password,
    String confirmationPassword,
  ) async {
    try {
      state = {...state, 'status': AuthState.loading, 'error': null};
      // Call API
      await AuthService.register(name, email, password, confirmationPassword);

      // Update state to authenticated
      state = {'status': AuthState.isRegistered, 'user': null, 'error': null};
    } catch (e) {
      // Extract error message from Exception
      String errorMessage;
      if (e is Exception) {
        // Get clean error message without 'Exception: ' prefix
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else {
        errorMessage = e.toString();
      }

      // Update state with formatted error
      state = {'status': AuthState.error, 'user': null, 'error': errorMessage};
    }
  }

  // Logout user
  Future<void> logout() async {
    state = {...state, 'status': AuthState.loading};

    try {
      // Call API
      final response = await AuthService.logout();

      if (response == true) {
        logger.fine('Logout successful on server');

        // Hapus data user dari storage
        await StorageHelper.clearUserData();

        // Update state ke unauthenticated
        state = {
          'status': AuthState.unauthenticated,
          'user': null,
          'error': null,
        };
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      state = {
        'status': AuthState.error,
        'user': state['user'],
        'error': 'Failed to logout',
      };
    }
  }

  void clearError() {
    // Clear error state
    state = {...state, 'error': null};
  }
}

// Provider that can be used throughout the app
final authProvider =
    StateNotifierProvider<AuthStateNotifier, Map<String, dynamic>>((ref) {
      return AuthStateNotifier();
    });
