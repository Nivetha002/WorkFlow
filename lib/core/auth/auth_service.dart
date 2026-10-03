import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
  }) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() {
    return _auth.signOut();
  }
}