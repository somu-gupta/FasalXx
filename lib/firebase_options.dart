import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase configuration for this app.
///
/// Run `flutterfire configure` to replace this placeholder with the generated
/// options for your Firebase project before calling `Firebase.initializeApp`.
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
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase options have not been configured for Linux. '
          'Run `flutterfire configure` to generate lib/firebase_options.dart.',
        );
      default:
        throw UnsupportedError(
          'Firebase options are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBz59RbdIO7z5AYOzGz6u2X5DSHs2tzO-0',
    appId: '1:115733748109:web:4e0aef1671ef4d437d45c4',
    messagingSenderId: '115733748109',
    projectId: 'fasalx-197fc',
    authDomain: 'fasalx-197fc.firebaseapp.com',
    storageBucket: 'fasalx-197fc.firebasestorage.app',
    measurementId: 'G-6VHFBC2YQ7',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCrJ8k7KKIi48nfjskTRsJuCbXdkdtxaUE',
    appId: '1:115733748109:ios:31ba06fffa71cc937d45c4',
    messagingSenderId: '115733748109',
    projectId: 'fasalx-197fc',
    storageBucket: 'fasalx-197fc.firebasestorage.app',
    iosBundleId: 'com.example.fasalxApp',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCrJ8k7KKIi48nfjskTRsJuCbXdkdtxaUE',
    appId: '1:115733748109:ios:31ba06fffa71cc937d45c4',
    messagingSenderId: '115733748109',
    projectId: 'fasalx-197fc',
    storageBucket: 'fasalx-197fc.firebasestorage.app',
    iosBundleId: 'com.example.fasalxApp',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBX0pVGGzzfJx4o0314-uRDdCzQWZT6vMo',
    appId: '1:115733748109:android:18de94469ea454c87d45c4',
    messagingSenderId: '115733748109',
    projectId: 'fasalx-197fc',
    storageBucket: 'fasalx-197fc.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBz59RbdIO7z5AYOzGz6u2X5DSHs2tzO-0',
    appId: '1:115733748109:web:80cd94051cd6d6807d45c4',
    messagingSenderId: '115733748109',
    projectId: 'fasalx-197fc',
    authDomain: 'fasalx-197fc.firebaseapp.com',
    storageBucket: 'fasalx-197fc.firebasestorage.app',
    measurementId: 'G-BYXDPJQZ6F',
  );

}