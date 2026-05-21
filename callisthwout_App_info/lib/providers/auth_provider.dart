import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Wraps FirebaseAuth and exposes the current user plus helper methods.
class AppAuthProvider extends ChangeNotifier {
  User? get currentUser => FirebaseAuth.instance.currentUser;

  String get displayName =>
      currentUser?.displayName?.isNotEmpty == true
          ? currentUser!.displayName!
          : (currentUser?.email?.split('@').first ?? 'Athlete');

  String get email => currentUser?.email ?? '';

  /// Sign in with email + password. Returns a descriptive error message on
  /// failure, or null on success.
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('signInWithEmail [${e.code}]: ${e.message}');
      return _mapError(e);
    } catch (e) {
      debugPrint('signInWithEmail unexpected: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Create a new account. Returns a descriptive error message on failure,
  /// or null on success.
  Future<String?> createAccount(
      String name, String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      // Update display name
      await cred.user?.updateDisplayName(name);
      await cred.user?.reload();
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('createAccount [${e.code}]: ${e.message}');
      return _mapError(e);
    } catch (e) {
      debugPrint('createAccount unexpected: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Send a password-reset email.
  Future<String?> sendPasswordReset(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('sendPasswordReset [${e.code}]: ${e.message}');
      return _mapError(e);
    } catch (e) {
      return 'Failed to send reset email. Please try again.';
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      // ── Sign-in errors ──────────────────────────────────────────────────
      case 'user-not-found':
        return 'No account found with that email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      // Firebase SDK v9+ consolidates wrong-password & user-not-found into this
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Incorrect email or password. Please check and try again.';

      // ── Account creation errors ─────────────────────────────────────────
      case 'email-already-in-use':
        return 'An account with this email already exists. Try signing in.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';

      // ── Common errors ───────────────────────────────────────────────────
      case 'invalid-email':
        return 'The email address is not valid. Please check it.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';

      // ── Configuration errors ────────────────────────────────────────────
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled in the Firebase console.\n'
            'Go to Firebase Console → Authentication → Sign-in method → enable Email/Password.';
      case 'configuration-not-found':
        return 'Firebase is not configured correctly. Please try again later.';
      case 'app-not-authorized':
        return 'This app is not authorised to use Firebase Authentication.';
      case 'api-key-not-valid':
        return 'Firebase API key is not valid. Please check configuration.';
      case 'internal-error':
        return 'Firebase internal error. Please try again.';

      // ── Catch-all with visible code for debugging ──────────────────────
      default:
        final msg = e.message;
        if (msg != null && msg.isNotEmpty && msg != 'Error') {
          return msg;
        }
        return 'Authentication error (${e.code}). Please try again.';
    }
  }
}
