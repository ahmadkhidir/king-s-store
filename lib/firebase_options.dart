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
    apiKey: 'AIzaSyAG4TfKr3vgdVMhtQNxxl8-NoWP-ECuAsU',
    appId: '1:587690026661:web:e0019d3ebbf78a20a30f4c',
    messagingSenderId: '587690026661',
    projectId: 'sales-ai-demo',
    authDomain: 'sales-ai-demo.firebaseapp.com',
    storageBucket: 'sales-ai-demo.appspot.com',
    measurementId: 'G-WGE344KCJC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDLu6KrxNzg7PR4lUeU5CzJZLgJ0HP4AhI',
    appId: '1:587690026661:android:b75cc98fb24e0bf6a30f4c',
    messagingSenderId: '587690026661',
    projectId: 'sales-ai-demo',
    storageBucket: 'sales-ai-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAR5zvwtEfYfVGW4Gxj6bEuVjEtQTwJU0I',
    appId: '1:587690026661:ios:47ca0ea4bcf77f0ea30f4c',
    messagingSenderId: '587690026661',
    projectId: 'sales-ai-demo',
    storageBucket: 'sales-ai-demo.appspot.com',
    iosBundleId: 'com.example.salesAiExamples',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAR5zvwtEfYfVGW4Gxj6bEuVjEtQTwJU0I',
    appId: '1:587690026661:ios:3a4d1b2fa5bab88ba30f4c',
    messagingSenderId: '587690026661',
    projectId: 'sales-ai-demo',
    storageBucket: 'sales-ai-demo.appspot.com',
    iosBundleId: 'com.example.salesAiExamples.RunnerTests',
  );
}
