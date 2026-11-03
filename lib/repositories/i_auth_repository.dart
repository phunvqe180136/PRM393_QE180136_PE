import 'package:firebase_auth/firebase_auth.dart';
import '../core/results/app_result.dart';

/// Contract interface defining Authentication business boundaries
/// Author: Nguyen Vinh Phu (QE180136)
abstract interface class IAuthRepository {
  User? get activeUser;
  Stream<User?> get userSessionStream;

  Future<AppResult<UserCredential>> signUp({
    required String email,
    required String password,
  });

  Future<AppResult<UserCredential>> logIn({
    required String email,
    required String password,
  });

  Future<AppResult<void>> logOut();
}

