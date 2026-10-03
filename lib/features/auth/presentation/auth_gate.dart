import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../main.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return HomeScreen(
            authService: authService,
          );
        }

        return LoginScreen(
          authService: authService,
        );
      },
    );
  }
}