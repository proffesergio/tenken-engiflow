import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Must be a top-level function — runs in an isolate when app is terminated
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  // Firebase is already initialised by the OS-level FlutterFire plugin at this
  // point. Nothing else needed for most apps.
}

class FcmService {
  // FCM is not supported on Windows or Linux desktop
  static bool get _supported =>
      !kIsWeb &&
      (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  /// Register the background handler. Call this in main() before runApp().
  static void registerBackgroundHandler() {
    if (!_supported) return;
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  /// Request permission, fetch token, save it to Firestore, and set up refresh.
  /// Call this after a successful login (uid is the Firebase Auth UID).
  static Future<void> initialize(String uid) async {
    if (!_supported) return;

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await messaging.getToken();
    if (token != null) await _saveToken(uid, token);

    // Keep the stored token up-to-date when it rotates
    messaging.onTokenRefresh.listen((newToken) => _saveToken(uid, newToken));
  }

  static Future<void> _saveToken(String uid, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  /// Call on logout to remove this device's token from Firestore.
  static Future<void> removeToken(String uid) async {
    if (!_supported) return;
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });
  }
}
