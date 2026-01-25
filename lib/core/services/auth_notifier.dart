import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    // Listen to Firebase auth changes and notify router
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners(); // ← this triggers redirect re-evaluation
    });
  }

  User? _currentUser;
  User? get currentUser => _currentUser;

  late final StreamSubscription<User?> _authSubscription;

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
