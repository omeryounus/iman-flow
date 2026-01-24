import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'service_locator.dart';
import '../../features/profile/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final UserService _userService = getIt<UserService>();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> initialize() async {
    try {
      // Version 7.x singleton initialization
      // Note: serverClientId is required for Android to avoid clientConfigurationError
      await _googleSignIn.initialize(
        serverClientId: '504848553840-rsiqcn73bqljika9l9cca4fsieof6oe4.apps.googleusercontent.com',
      );
    } catch (e) {
      print('AuthService: Google Sign In initialization error: $e');
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      await _userService.createOrUpdateProfile();
      return credential;
    } catch (e) {
      print('AuthService: Anonymous sign in error: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('AuthService: Starting Google Sign-In flow (authenticate)...');
      // In 7.x, authenticate() returns the account directly
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      
      if (googleUser == null) {
        print('AuthService: Google Sign-In cancelled by user or failed');
        return null;
      }
      print('AuthService: Google user authenticated: ${googleUser.email}');

      // Get ID Token for Firebase Authentication
      print('AuthService: Retrieving tokens from Google authentication object...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      print('AuthService: idToken retrieved: ${idToken != null}');

      // For Access Token, in 7.x we use the authorizationClient
      print('AuthService: Authorizing scopes (email, profile) for accessToken...');
      final authorization = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);
      final String? accessToken = authorization.accessToken;
      print('AuthService: accessToken retrieved: ${accessToken != null}');

      if (idToken == null) {
        print('AuthService: Critical Error - idToken is null, cannot proceed to Firebase');
        return null;
      }

      print('AuthService: Signing into Firebase with Google credentials...');
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      print('AuthService: Firebase login successful: ${userCredential.user?.uid}');

      print('AuthService: Creating/Updating user profile in Firestore...');
      await _userService.createOrUpdateProfile(
        displayName: userCredential.user?.displayName,
      );
      print('AuthService: Google Sign-In complete');
      
      return userCredential;
    } catch (e) {
      print('AuthService: Google Sign-In Exception: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      // Use disconnect or signOut depending on preference
      await _googleSignIn.signOut();
    } catch (e) {
      print('AuthService: Google sign out error: $e');
    }
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}
