// File generated manually from Firebase Console config values.
// project: callisthwout-app

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbvIPFlFP9-sKbRW8x4Wg3PWWnsOs6YnQ',
    appId: '1:265730208038:android:30407e93cdee37a53b51e7',
    messagingSenderId: '265730208038',
    projectId: 'callisthwout-app',
    storageBucket: 'callisthwout-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVlfuZWTTVT62566lxBnu7ibtWneJDgkI',
    appId: '1:265730208038:ios:4897409c3915ad6c3b51e7',
    messagingSenderId: '265730208038',
    projectId: 'callisthwout-app',
    storageBucket: 'callisthwout-app.firebasestorage.app',
    iosBundleId: 'com.example.callisthwoutApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBVlfuZWTTVT62566lxBnu7ibtWneJDgkI',
    appId: '1:265730208038:ios:4897409c3915ad6c3b51e7',
    messagingSenderId: '265730208038',
    projectId: 'callisthwout-app',
    storageBucket: 'callisthwout-app.firebasestorage.app',
    iosBundleId: 'com.example.callisthwoutApp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBbvIPFlFP9-sKbRW8x4Wg3PWWnsOs6YnQ',
    appId: '1:265730208038:android:30407e93cdee37a53b51e7',
    messagingSenderId: '265730208038',
    projectId: 'callisthwout-app',
    storageBucket: 'callisthwout-app.firebasestorage.app',
  );
}
