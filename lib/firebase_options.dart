// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAQcu9NOUqf4D1p3WtuX5vyklMFUyI7_bQ',
    appId: '1:563138394872:web:4680cfc12a90da11e8990d',
    messagingSenderId: '563138394872',
    projectId: 'push-notification-b443f',
    authDomain: 'push-notification-b443f.firebaseapp.com',
    storageBucket: 'push-notification-b443f.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAvqHyb2WHQaDtCbc_dunrfAVemasi9AZY',
    appId: '1:563138394872:android:3f991a4186b60fd2e8990d',
    messagingSenderId: '563138394872',
    projectId: 'push-notification-b443f',
    storageBucket: 'push-notification-b443f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzPOj7fnUnQuGCMzqO2GfvBXCNly2Jpm4',
    appId: '1:563138394872:ios:01b9b57f317390a4e8990d',
    messagingSenderId: '563138394872',
    projectId: 'push-notification-b443f',
    storageBucket: 'push-notification-b443f.appspot.com',
    iosBundleId: 'com.example.pushtrial',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAQcu9NOUqf4D1p3WtuX5vyklMFUyI7_bQ',
    appId: '1:563138394872:web:5b25487bf6a7ea3be8990d',
    messagingSenderId: '563138394872',
    projectId: 'push-notification-b443f',
    authDomain: 'push-notification-b443f.firebaseapp.com',
    storageBucket: 'push-notification-b443f.appspot.com',
  );
}
