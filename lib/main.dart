import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app/app.dart';
import 'core/services/service_locator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Main: Starting application...');
  
  // Enable Edge-to-Edge for Android 15+
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // Initialize Firebase (optional - app works in demo mode without it)
  try {
    print('Main: Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Main: Firebase initialized');
    
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization skipped: $e');
      print('Running in demo mode without Firebase.');
    }
  }
  
  // Setup service locator for dependency injection
  print('Main: Setting up Service Locator...');
  await setupServiceLocator();
  print('Main: Service Locator ready');
  
  runApp(const ImanFlowApp());
}
