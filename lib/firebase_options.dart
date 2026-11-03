// Firebase configuration for the RecipeBox app.
//
// IMPORTANT: these are the CLIENT-SIDE keys only. They are safe to ship in the
// app and they are what the Firebase console gives you under
// Project settings -> Your apps -> SDK setup and configuration.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'This app is built for Android only.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      default:
        throw UnsupportedError(
          'This app is built for Android only.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCcX_aD54tODmQh1zqMYtYDEjR_yQ-eQFY',
    appId: '1:129270298736:android:828c6a0317cefb95ae5cb5',
    messagingSenderId: '129270298736',
    projectId: 'prm393-pe26',
    storageBucket: 'prm393-pe26.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCcX_aD54tODmQh1zqMYtYDEjR_yQ-eQFY',
    appId: '1:129270298736:android:828c6a0317cefb95ae5cb5',
    messagingSenderId: '129270298736',
    projectId: 'prm393-pe26',
    storageBucket: 'prm393-pe26.firebasestorage.app',
    iosBundleId: 'com.company.RecipeBox',
  );
}
