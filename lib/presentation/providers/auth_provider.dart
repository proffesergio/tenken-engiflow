import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _firebaseUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  
  // Getters
  User? get firebaseUser => _firebaseUser;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  
  // Simple getter for compatibility (returns firebaseUser)
  User? get user => _firebaseUser;
  
  // Constructor - listen to auth state
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }
  
  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      
      if (userDoc.exists) {
        _userData = userDoc.data() as Map<String, dynamic>;
      } else {
        // Create default user data if not exists
        _userData = {
          'uid': uid,
          'email': _firebaseUser?.email,
          'displayName': _firebaseUser?.displayName ?? 'User',
          'role': 'engineer',
          'department': 'Not assigned',
          'createdAt': DateTime.now().toIso8601String(),
        };
        await _firestore.collection('users').doc(uid).set(_userData!);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }
  
  // Login method
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isLoading = false;
      _successMessage = 'Login successful!';
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (e.code == 'user-not-found') {
        _error = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        _error = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        _error = 'Invalid email address';
      } else {
        _error = 'Login failed: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Login failed. Please try again.';
      notifyListeners();
      return false;
    }
  }
  
  // Registration method
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required String department,
  }) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (result.user != null) {
        // Create user data
        Map<String, dynamic> userData = {
          'uid': result.user!.uid,
          'email': email,
          'displayName': displayName,
          'role': role,
          'department': department,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };
        
        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userData);
        
        _isLoading = false;
        _successMessage = 'Registration successful! You can now login.';
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      _error = 'Registration failed';
      notifyListeners();
      return false;
      
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (e.code == 'email-already-in-use') {
        _error = 'Email already registered';
      } else if (e.code == 'weak-password') {
        _error = 'Password is too weak (minimum 6 characters)';
      } else if (e.code == 'invalid-email') {
        _error = 'Invalid email address';
      } else {
        _error = 'Registration failed: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Registration failed. Please try again.';
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    await _auth.signOut();
    _userData = null;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
  
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}