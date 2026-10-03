import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (isLogin) {
        await widget.authService.login(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        await widget.authService.register(
          email: emailController.text,
          password: passwordController.text,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = authErrorMessage(error.code);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        errorMessage = 'Something went wrong. Try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must contain at least 6 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.checklist_rounded,
                        size: 36,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Welcome to WorkFlow',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      isLogin
                          ? 'Sign in to manage your tasks.'
                          : 'Create your WorkFlow account.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter your email';
                      }

                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your password';
                      }

                      if (value.length < 6) {
                        return 'Password must contain at least 6 characters';
                      }

                      return null;
                    },
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : submit,
                      child: isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Text(isLogin ? 'Sign in' : 'Create account'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        setState(() {
                          isLogin = !isLogin;
                          errorMessage = null;
                        });
                      },
                      child: Text(
                        isLogin
                            ? 'Create a new account'
                            : 'Already have an account? Sign in',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}