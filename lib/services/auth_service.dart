import 'package:firebase_auth/firebase_auth.dart';

/// Authentication Management Service for RecipeBox
/// Author: Nguyen Vinh Phu (QE180136)
class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Returns the actively signed-in Firebase user, or null
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream listening for real-time authentication state updates
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Create a new account with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential;
    } on FirebaseAuthException catch (error) {
      throw _parseAuthException(error);
    } catch (e) {
      throw 'An error occurred during registration: ${e.toString()}';
    }
  }

  /// Sign in with an existing email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential;
    } on FirebaseAuthException catch (error) {
      throw _parseAuthException(error);
    } catch (e) {
      throw 'An unexpected error occurred during login.';
    }
  }

  /// Sign out the active user session
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Converts Firebase authentication exceptions into human-friendly error messages
  String _parseAuthException(FirebaseAuthException exception) {
    if (exception.message != null && exception.message!.trim().isNotEmpty) {
      return exception.message!.trim();
    }

    switch (exception.code) {
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed (${exception.code}). Please verify your credentials.';
    }
  }
}
