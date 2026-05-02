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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyBg122djf_B5k-rxrUviIxVVppUW9_w3os',
    appId: '1:717625012210:web:8396e384b900ea150cc56b',
    messagingSenderId: '717625012210',
    projectId: 'sobun-app-2026',
    authDomain: 'sobun-app-2026.firebaseapp.com',
    storageBucket: 'sobun-app-2026.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDiCk2tSFOIKF_gbluJY0dmo-_12rFCqcc',
    appId: '1:717625012210:android:b77ed34ff6d9a9980cc56b',
    messagingSenderId: '717625012210',
    projectId: 'sobun-app-2026',
    storageBucket: 'sobun-app-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAWgSDfm1uxdtZo-OwpHn8gbtu5Nqck4l0',
    appId: '1:717625012210:ios:aa7ee6ca10083b570cc56b',
    messagingSenderId: '717625012210',
    projectId: 'sobun-app-2026',
    storageBucket: 'sobun-app-2026.firebasestorage.app',
    iosBundleId: 'com.example.sobunApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAWgSDfm1uxdtZo-OwpHn8gbtu5Nqck4l0',
    appId: '1:717625012210:ios:aa7ee6ca10083b570cc56b',
    messagingSenderId: '717625012210',
    projectId: 'sobun-app-2026',
    storageBucket: 'sobun-app-2026.firebasestorage.app',
    iosBundleId: 'com.example.sobunApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBg122djf_B5k-rxrUviIxVVppUW9_w3os',
    appId: '1:717625012210:web:2b24759cebe6a8700cc56b',
    messagingSenderId: '717625012210',
    projectId: 'sobun-app-2026',
    authDomain: 'sobun-app-2026.firebaseapp.com',
    storageBucket: 'sobun-app-2026.firebasestorage.app',
  );
}
