import 'package:firebase_auth/firebase_auth.dart';
import '../core/results/app_result.dart';
import 'i_auth_repository.dart';

/// Concrete Firebase Authentication Repository implementation
/// Author: Nguyen Vinh Phu (QE180136)
class FirebaseAuthRepository implements IAuthRepository {
  final FirebaseAuth _sdk;

  FirebaseAuthRepository({FirebaseAuth? sdk}) : _sdk = sdk ?? FirebaseAuth.instance;

  @override
  User? get activeUser => _sdk.currentUser;

  @override
  Stream<User?> get userSessionStream => _sdk.authStateChanges();

  @override
  Future<AppResult<UserCredential>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _sdk.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return AppResult.success(credential);
    } on FirebaseAuthException catch (err) {
      return AppResult.failure(_mapAuthErrorCode(err));
    } catch (e) {
      return AppResult.failure('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<AppResult<UserCredential>> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _sdk.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return AppResult.success(credential);
    } on FirebaseAuthException catch (err) {
      return AppResult.failure(_mapAuthErrorCode(err));
    } catch (e) {
      return AppResult.failure('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<AppResult<void>> logOut() async {
    try {
      await _sdk.signOut();
      return const AppResult.success(null);
    } catch (e) {
      return AppResult.failure('Unable to sign out: ${e.toString()}');
    }
  }

  String _mapAuthErrorCode(FirebaseAuthException e) {
    if (e.message != null && e.message!.trim().isNotEmpty) {
      return e.message!.trim();
    }
    return switch (e.code) {
      'email-already-in-use' => 'The email address is already in use by another account.',
      'invalid-email' => 'The email address is badly formatted.',
      'weak-password' => 'The password provided is too weak.',
      'user-not-found' || 'wrong-password' || 'invalid-credential' => 'Invalid email or password.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many login attempts. Please try again later.',
      _ => 'Authentication failure: ${e.code}',
    };
  }
}

