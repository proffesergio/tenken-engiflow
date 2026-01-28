import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tenken_engiflow/core/services/firebase_service.dart';
import 'package:tenken_engiflow/data/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseService.auth;
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  
  // SIMPLIFIED: Direct registration without complex error handling
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required String department,
  }) async {
    try {
      print('1. Creating Firebase Auth user...');
      
      // Create user in Firebase Auth
      final UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final User? user = authResult.user;
      if (user == null) {
        throw Exception('User creation failed - no user returned');
      }
      
      print('✅ Auth user created: ${user.uid}');
      
      // Create user data model
      final UserModel userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: role,
        department: department,
        createdAt: DateTime.now(),
      );
      
      print('2. Saving to Firestore...');
      
      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());
      
      print('✅ User saved to Firestore');
      
      return userModel;
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }
  
  // SIMPLIFIED: Direct login
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final User? user = authResult.user;
      if (user == null) {
        throw Exception('Login failed - no user returned');
      }
      
      // Get user data from Firestore
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) {
        throw Exception('User data not found in database');
      }
      
      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }
  
  Future<void> logout() async {
    await _auth.signOut();
  }
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}