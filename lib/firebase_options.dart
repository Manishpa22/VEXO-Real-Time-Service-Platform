import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase options generated from google-services.json
/// Project: vexo-63471
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCdKTyrg-mEUIN82Sf-KySQfEFi_G7ps_k',
    appId: '1:1047545744040:web:286f2af6aeb8bbabf2909d',
    messagingSenderId: '1047545744040',
    projectId: 'vexo-63471',
    authDomain: 'vexo-63471.firebaseapp.com',
    storageBucket: 'vexo-63471.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnV02c7JhkAPSlzl1gajti37tpEbvkva8',
    appId: '1:1047545744040:android:286f2af6aeb8bbabf2909d',
    messagingSenderId: '1047545744040',
    projectId: 'vexo-63471',
    storageBucket: 'vexo-63471.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAnV02c7JhkAPSlzl1gajti37tpEbvkva8',
    appId: '1:1047545744040:ios:286f2af6aeb8bbabf2909d',
    messagingSenderId: '1047545744040',
    projectId: 'vexo-63471',
    storageBucket: 'vexo-63471.firebasestorage.app',
    iosBundleId: 'com.vexo.vexoApp',
  );
}
