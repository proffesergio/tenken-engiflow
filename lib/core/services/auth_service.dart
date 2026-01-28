// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tenken_engiflow/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();
            
        if (userDoc.exists) {
          UserModel user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          return {'success': true, 'user': user, 'message': 'Login successful'};
        } else {
          return {'success': false, 'message': 'User data not found in database'};
        }
      }
      return {'success': false, 'message': 'Login failed'};
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }
  
// In lib/core/services/auth_service.dart, update the registerWithEmail method:
Future<Map<String, dynamic>> registerWithEmail({
  required String email,
  required String password,
  required String displayName,
  required String role,
  required String department,
}) async {
  print('=== REGISTRATION STARTED ===');
  print('Email: $email');
  print('Role: $role');
  print('Department: $department');
  
  try {
    // Validate role
    if (!['engineer', 'supervisor', 'admin'].contains(role.toLowerCase())) {
      print('❌ Invalid role: $role');
      return {'success': false, 'message': 'Invalid role selected'};
    }
    
    // Create user in Firebase Auth
    print('📝 Creating Firebase Auth user...');
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    print('✅ Firebase Auth user created: ${result.user?.uid}');
    
    if (result.user != null) {
      try {
        // Create user document in Firestore
        UserModel newUser = UserModel(
          uid: result.user!.uid,
          email: email,
          displayName: displayName,
          role: role.toLowerCase(),
          department: department,
          createdAt: DateTime.now(),
        );
        
        print('📝 Saving to Firestore collection "users"...');
        print('User data: ${newUser.toMap()}');
        
        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toMap());
            
        print('✅ Firestore document saved successfully!');
        print('=== REGISTRATION COMPLETE ===');
        
        return {
          'success': true, 
          'user': newUser, 
          'message': 'Registration successful! You can now login.'
        };
      } catch (firestoreError) {
        print('❌ Firestore Error: $firestoreError');
        print('Stack trace: ${firestoreError.toString()}');
        
        // If Firestore fails, delete the auth user to keep consistency
        try {
          await result.user!.delete();
          print('🗑️ Deleted auth user due to Firestore failure');
        } catch (deleteError) {
          print('❌ Could not delete auth user: $deleteError');
        }
        
        return {'success': false, 'message': 'Database error: $firestoreError'};
      }
    }
    print('❌ No user created');
    return {'success': false, 'message': 'Registration failed'};
  } on FirebaseAuthException catch (e) {
    print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
    String errorMessage;
    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = 'This email is already registered';
        break;
      case 'weak-password':
        errorMessage = 'Password is too weak (min 6 characters)';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email format';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Email/password accounts are not enabled';
        break;
      default:
        errorMessage = 'Registration failed: ${e.message}';
    }
    return {'success': false, 'message': errorMessage};
  } catch (e) {
    print('❌ Unexpected Error: $e');
    print('Type: ${e.runtimeType}');
    return {'success': false, 'message': 'Registration error: $e'};
  }
}
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  Stream<UserModel?> get userStream {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return null;
      
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (userDoc.exists) {
          return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
        }
        return null;
      } catch (e) {
        return null;
      }
    });
  }
}