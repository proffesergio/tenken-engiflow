import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static bool _isInitialized = false;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('🚀 Initializing Firebase...');
      
      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "YOUR_API_KEY", // Will be replaced by google-services.json
          appId: "YOUR_APP_ID",
          messagingSenderId: "YOUR_SENDER_ID",
          projectId: "tenken-engiflow",
        ),
      );
      
      print('✅ Firebase Core initialized');
      
      // Test Firebase Auth
      final auth = FirebaseAuth.instance;
      print('✅ Firebase Auth instance created');
      
      // Test Firestore
      final firestore = FirebaseFirestore.instance;
      print('✅ Firestore instance created');
      
      _isInitialized = true;
      print('🎉 Firebase initialization complete!');
      
    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }
  
  static FirebaseAuth get auth {
    if (!_isInitialized) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return FirebaseAuth.instance;
  }
  
  static FirebaseFirestore get firestore {
    if (!_isInitialized) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return FirebaseFirestore.instance;
  }
}