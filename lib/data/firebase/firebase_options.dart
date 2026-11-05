import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'Firebase is configured for Android with google-services.json. Add GoogleService-Info.plist before running on iOS.',
    );
  }

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyC7LrTkRHV7UvS59JC093HuuB_Zs9eSCVQ',
    appId: '1:1064908478392:android:b1d53d0bca97652dc2214d',
    messagingSenderId: '1064908478392',
    projectId: 'punemetro-go',
    storageBucket: 'punemetro-go.firebasestorage.app',
  );
}
