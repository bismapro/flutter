import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _user;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;

  // Mock login method
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication logic
      if (email.isNotEmpty && password.isNotEmpty) {
        _user = {
          'id': '1',
          'name': 'Ahmad Ibrahim',
          'email': email,
          'avatar': '',
          'joinDate': DateTime.now().toIso8601String(),
        };
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Mock signup method
  Future<bool> signup(String name, String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock signup logic
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        _user = {
          'id': '1',
          'name': name,
          'email': email,
          'avatar': '',
          'joinDate': DateTime.now().toIso8601String(),
        };
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        throw Exception('Please fill all required fields');
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Mock Google sign in
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      _user = {
        'id': '2',
        'name': 'Google User',
        'email': 'user@gmail.com',
        'avatar': '',
        'provider': 'google',
        'joinDate': DateTime.now().toIso8601String(),
      };
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to sign in with Google');
      _setLoading(false);
      return false;
    }
  }

  // Mock Facebook sign in
  Future<bool> signInWithFacebook() async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      _user = {
        'id': '3',
        'name': 'Facebook User',
        'email': 'user@facebook.com',
        'avatar': '',
        'provider': 'facebook',
        'joinDate': DateTime.now().toIso8601String(),
      };
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to sign in with Facebook');
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isAuthenticated = false;
    _user = null;
    _clearError();
    notifyListeners();
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to send reset email');
      _setLoading(false);
      return false;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
