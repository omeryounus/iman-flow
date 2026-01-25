import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/theme.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: ImanFlowTheme.bgTop,
            body: Center(
              child: CircularProgressIndicator(color: ImanFlowTheme.gold),
            ),
          );
        }

        // Just render child, redirection is handled by GoRouter
        return child;
      },
    );
  }
}
