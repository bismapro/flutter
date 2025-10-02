import 'package:google_sign_in/google_sign_in.dart';
import 'package:test_flutter/core/utils/logger.dart';

class GoogleService {
  final _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  GoogleService() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      logger.fine('Failed to initialize Google Sign-In: $e');
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  Future<GoogleSignInAccount> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    try {
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'], // Specify required scopes
      );
      return account;
    } on GoogleSignInException catch (e) {
      logger.fine(
        "Google Sign In error: code: ${e.code.name} description:${e.description} details:${e.details}",
      );
      rethrow;
    } catch (error) {
      logger.fine('Unexpected Google Sign-In error: $error');
      rethrow;
    }
  }
}
