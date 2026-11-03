import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/firebase_auth_repository.dart';
import '../repositories/i_auth_repository.dart';

/// Legacy Service Facade delegating to Clean Architecture Repository
/// Author: Nguyen Vinh Phu (QE180136)
class AuthService {
  final IAuthRepository _repo;

  AuthService({IAuthRepository? repository})
      : _repo = repository ?? FirebaseAuthRepository();

  User? get currentUser => _repo.activeUser;
  Stream<User?> get authStateChanges => _repo.userSessionStream;

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final result = await _repo.signUp(email: email, password: password);
    if (result.isFailure) {
      throw result.errorOrNull!;
    }
    return result.dataOrNull!;
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final result = await _repo.logIn(email: email, password: password);
    if (result.isFailure) {
      throw result.errorOrNull!;
    }
    return result.dataOrNull!;
  }

  Future<void> signOut() async {
    final result = await _repo.logOut();
    if (result.isFailure) {
      throw result.errorOrNull!;
    }
  }
}
