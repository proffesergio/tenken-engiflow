import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTester {
  static Future<void> testCompleteFlow() async {
    print('\n\n=== FIREBASE COMPLETE TEST ===\n');
    
    try {
      // 1. Test Auth
      print('1. Testing Firebase Auth...');
      final auth = FirebaseAuth.instance;
      print('✅ Auth instance created');
      
      // 2. Test Firestore
      print('\n2. Testing Firestore...');
      final firestore = FirebaseFirestore.instance;
      print('✅ Firestore instance created');
      
      // 3. Test Write
      print('\n3. Testing Firestore write...');
      const testId = 'flutter_test_${DateTime.now().millisecondsSinceEpoch}';
      await firestore.collection('debug_tests').doc(testId).set({
        'test': 'Firestore write test',
        'timestamp': DateTime.now().toIso8601String(),
        'platform': 'Android',
      });
      print('✅ Firestore write successful');
      
      // 4. Test Read
      print('\n4. Testing Firestore read...');
      final doc = await firestore.collection('debug_tests').doc(testId).get();
      print('✅ Firestore read successful: ${doc.data()}');
      
      // 5. Test Users Collection
      print('\n5. Testing users collection...');
      await firestore.collection('users').doc('test_user').set({
        'uid': 'test_user',
        'email': 'test@test.com',
        'displayName': 'Test User',
        'role': 'engineer',
        'department': 'Testing',
        'createdAt': DateTime.now().toIso8601String(),
      });
      print('✅ Users collection write successful');
      
      // 6. Cleanup
      print('\n6. Cleaning up test data...');
      await firestore.collection('debug_tests').doc(testId).delete();
      await firestore.collection('users').doc('test_user').delete();
      print('✅ Cleanup complete');
      
      print('\n=== ALL TESTS PASSED ===\n');
      
    } catch (e) {
      print('\n❌ TEST FAILED: $e');
      print('Stack trace:');
      print(e.toString());
    }
  }
}