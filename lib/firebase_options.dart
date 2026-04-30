import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured. Run flutterfire configure again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'This platform is not configured. Run flutterfire configure again.',
        );
      default:
        throw UnsupportedError(
          'This platform is not supported.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyCH0B0Plv9jbTBRX1TXMvrywmh03wp8xMk',
  appId: '1:70811641155:android:f80d3ba1fdd5b2eabf3bf6',
  messagingSenderId: '70811641155',
  projectId: 'proj2-database',
  storageBucket: 'proj2-database.firebasestorage.app',
);

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PASTE_IOS_API_KEY_HERE',
    appId: 'PASTE_IOS_APP_ID_HERE',
    messagingSenderId: 'PASTE_MESSAGING_SENDER_ID_HERE',
    projectId: 'PASTE_PROJECT_ID_HERE',
    storageBucket: 'PASTE_STORAGE_BUCKET_HERE',
    iosBundleId: 'PASTE_IOS_BUNDLE_ID_HERE',
  );
}