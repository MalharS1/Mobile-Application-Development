// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'GOOGLE_API_KEY=your-new-google-api-key',
    appId: '1:159632032979:web:d70ef623c8d11e41800026',
    messagingSenderId: '159632032979',
    projectId: 'final-project-mobile-dev-db993',
    authDomain: 'final-project-mobile-dev-db993.firebaseapp.com',
    storageBucket: 'final-project-mobile-dev-db993.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'GOOGLE_API_KEY=your-new-google-api-key',
    appId: '1:159632032979:android:cc67283f0a48ecee800026',
    messagingSenderId: '159632032979',
    projectId: 'final-project-mobile-dev-db993',
    storageBucket: 'final-project-mobile-dev-db993.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'GOOGLE_API_KEY=your-new-google-api-key',
    appId: '1:159632032979:ios:086c6c7887f15ba4800026',
    messagingSenderId: '159632032979',
    projectId: 'final-project-mobile-dev-db993',
    storageBucket: 'final-project-mobile-dev-db993.appspot.com',
    iosBundleId: 'com.example.unifood',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'GOOGLE_API_KEY=your-new-google-api-key',
    appId: '1:159632032979:ios:8c98b73a1f5b945c800026',
    messagingSenderId: '159632032979',
    projectId: 'final-project-mobile-dev-db993',
    storageBucket: 'final-project-mobile-dev-db993.appspot.com',
    iosBundleId: 'com.example.unifood.RunnerTests',
  );
}