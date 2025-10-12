import 'package:dio/dio.dart';
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
      final data = await _getUserWithSingleRefresh();
      if (data != null) {
        // Sukses ambil dari server
        state = {
          'status': AuthState.authenticated,
          'user': data,
          'error': null,
        };
        // Sync ke storage agar up to date
        await StorageHelper.saveUser(data);
        return;
      }

      // Jika sampai sini berarti tidak dapat user dari server (401 sesudah refresh / null)
      await _fallbackToStorageOrUnauth();
    } on DioException catch (e) {
      logger.warning('Network/Dio error: ${e.type} ${e.response?.statusCode}');
      // Offline/timeouts atau error lain → fallback
      await _fallbackToStorageOrUnauth();
    } catch (e) {
      logger.warning('Unknown error: $e');
      await _fallbackToStorageOrUnauth(error: 'Failed to check auth status');
    }
  }

  /// Coba GET /current-user sekali; jika 401 → refresh token sekali → retry.
  /// return: map user bila sukses, atau null bila gagal.
  Future<Map<String, dynamic>?> _getUserWithSingleRefresh() async {
    try {
      final resp = await AuthService.getCurrentUser();
      final data = resp['data'] as Map<String, dynamic>?;
      if (data != null) return data;
      return null;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401) {
        logger.fine('Access token 401 → try refresh once');
        try {
          final r = await AuthService.refresh(); // pastikan ada endpoint ini
          final newAccess = r['token'] as String?;

          if (newAccess == null || newAccess.isEmpty) {
            logger.fine('Refresh failed: empty access token');
            return null;
          }

          // Simpan token baru
          await StorageHelper.saveToken(newAccess);

          // Retry get current user
          final retry = await AuthService.getCurrentUser();
          final data2 = retry['data'] as Map<String, dynamic>?;
          return data2;
        } catch (e2) {
          logger.warning('Refresh attempt failed: $e2');
          return null; // biar caller fallback ke storage
        }
      }
      rethrow; // error selain 401: lempar ke caller (akan fallback)
    }
  }

  /// Fallback ke storage (mode offline) atau set unauthenticated bila tidak ada data.
  Future<void> _fallbackToStorageOrUnauth({String? error}) async {
    logger.warning('Fallback to local storage...');

    final localUser = await StorageHelper.getUser();
    final localToken = await StorageHelper.getToken();

    if (localUser != null && localToken != null && localToken.isNotEmpty) {
      state = {
        'status': AuthState.authenticated,
        'user': localUser,
        'error': null,
      };
    } else {
      state = {
        'status': AuthState.unauthenticated,
        'user': null,
        'error': error,
      };
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
      if (data['token'] != null &&
          data['token'].toString().isNotEmpty) {
        await StorageHelper.saveToken(data['token']);
        logger.fine('Access Token saved: ${data['token']}');
      } else if (data['token'] != null && data['token'].toString().isNotEmpty) {
        await StorageHelper.saveToken(data['token']);
        logger.fine('Token saved: ${data['token']}');
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
          "phone": user['no_hp'].toString(),
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

      await StorageHelper.clearUserData();
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
