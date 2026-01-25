import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'service_locator.dart';
import '../../features/profile/services/user_service.dart';

class AuthService {
  // Singleton instance – do NOT instantiate with GoogleSignIn()
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = getIt<UserService>();

  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initializationDone => _initCompleter.future;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> initialize() async {
    print('AuthService: Initializing...');

    try {
      print('AuthService: Calling GoogleSignIn.initialize()...');

      // REQUIRED in 7.x – call exactly once, early in app lifecycle
      // serverClientId = your WEB client ID (from Google Cloud Console > Credentials > OAuth 2.0 Client IDs > Web application)
      // clientId = optional iOS client ID (from GoogleService-Info.plist or Google Cloud iOS client)
      await _googleSignIn.initialize(
        serverClientId:
            '504848553840-q3ob8p47nb7s605u2ddr4lurhg5fhd9f.apps.googleusercontent.com',
      );

      print('AuthService: GoogleSignIn initialized successfully');

      // Optional: start lightweight/silent auth restoration
      // This replaces old silent sign-in behavior
      final lightweightResult = await _googleSignIn.attemptLightweightAuthentication();
      if (lightweightResult != null) {
        print('AuthService: Lightweight auth succeeded for ${lightweightResult.email}');
      } else {
        print('AuthService: No lightweight auth session available');
      }

      // Wait for first Firebase auth state emission to unblock UI if needed
      await _auth.authStateChanges().first;

      print('AuthService: Initialization complete');
    } catch (e) {
      print('AuthService: Initialization failed: $e');
      // Decide if you want to rethrow or just complete
    } finally {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      await _userService.createOrUpdateProfile(
        displayName: 'Guest User',
      ); // handle anon case
      return credential;
    } catch (e) {
      print('AuthService: Anonymous sign in error: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('AuthService: Starting Google Sign-In...');

      // Use authenticate() on Android/iOS (7.x way)
      // This triggers the native Google sign-in UI
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        print('AuthService: Sign-in cancelled by user');
        return null;
      }

      print('AuthService: Google account selected: ${googleUser.email}');

      // Get the ID token (primary for Firebase)
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        print('AuthService: Error: idToken is null');
        return null;
      }

      print('AuthService: idToken obtained successfully');

      // accessToken is NOT directly available here in the same way anymore
      // For Firebase Auth, idToken alone is usually enough on mobile
      // If your backend needs accessToken, use googleUser.authorization(...) separately
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        // accessToken: null,  // omit unless you separately authorize
      );

      print('AuthService: Signing in to Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);

      print('AuthService: Firebase sign-in successful: ${userCredential.user?.uid}');

      await _userService.createOrUpdateProfile(
        displayName: userCredential.user?.displayName,
        email: userCredential.user?.email,
        photoURL: userCredential.user?.photoURL,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('Google signed out');
    } catch (e) {
      print('Google sign-out error: $e');
    }

    await _auth.signOut();
    print('Firebase signed out');
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await user.delete();
        print('Account deleted');
      } catch (e) {
        print('Delete account error: $e');
      }
    }
  }
}