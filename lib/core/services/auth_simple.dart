import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthSimpleService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // SIMPLE REGISTRATION THAT WORKS
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required String department,
  }) async {
    try {
      print('🚀 Starting registration for: $email');
      
      // 1. Create user in Firebase Auth
      final UserCredential authResult = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final User? user = authResult.user;
      if (user == null) {
        return {'success': false, 'message': 'Failed to create user'};
      }
      
      print('✅ Firebase Auth user created: ${user.uid}');
      
      // 2. Prepare user data
      final userData = {
        'uid': user.uid,
        'email': email,
        'displayName': displayName,
        'role': role,
        'department': department,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      // 3. Save to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData);
      
      print('✅ User data saved to Firestore');
      
      return {
        'success': true,
        'message': 'Registration successful!',
        'userId': user.uid,
        'userData': userData,
      };
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email already registered';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password too weak (min 6 chars)';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('❌ Registration error: $e');
      return {'success': false, 'message': 'Registration failed: ${e.toString()}'};
    }
  }
  
  // SIMPLE LOGIN THAT WORKS
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 Attempting login for: $email');
      
      final UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final User? user = authResult.user;
      if (user == null) {
        return {'success': false, 'message': 'Login failed'};
      }
      
      print('✅ Firebase Auth login successful: ${user.uid}');
      
      // Get user data from Firestore
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) {
        return {'success': false, 'message': 'User data not found'};
      }
      
      return {
        'success': true,
        'message': 'Login successful!',
        'userId': user.uid,
        'userData': userDoc.data(),
      };
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('❌ Login error: $e');
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }
  
  Future<void> logout() async {
    await _auth.signOut();
  }
}