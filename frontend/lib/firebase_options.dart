import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbu_Nehd66O1i3scAtZ8S4gwMinaJeqXY',
    appId: '1:530605585688:android:44e90a51991e52c9f31a6d',
    messagingSenderId: '530605585688',
    projectId: 'bharath-academy-1a1ce',
    storageBucket: 'bharath-academy-1a1ce.firebasestorage.app',
    databaseURL: 'https://bharath-academy-1a1ce-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBbu_Nehd66O1i3scAtZ8S4gwMinaJeqXY',
    appId: '1:530605585688:android:44e90a51991e52c9f31a6d',
    messagingSenderId: '530605585688',
    projectId: 'bharath-academy-1a1ce',
    storageBucket: 'bharath-academy-1a1ce.firebasestorage.app',
    databaseURL: 'https://bharath-academy-1a1ce-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBbu_Nehd66O1i3scAtZ8S4gwMinaJeqXY',
    appId: '1:530605585688:android:44e90a51991e52c9f31a6d',
    messagingSenderId: '530605585688',
    projectId: 'bharath-academy-1a1ce',
    storageBucket: 'bharath-academy-1a1ce.firebasestorage.app',
    databaseURL: 'https://bharath-academy-1a1ce-default-rtdb.firebaseio.com',
  );
}
