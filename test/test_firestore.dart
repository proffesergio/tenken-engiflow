import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTest {
  static Future<void> testConnection() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Test write
      await firestore.collection('test').doc('connection').set({
        'test': 'success',
        'timestamp': DateTime.now().toIso8601String(),
      });
      print('✅ Firestore write successful');
      
      // Test read
      DocumentSnapshot doc = await firestore.collection('test').doc('connection').get();
      if (doc.exists) {
        print('✅ Firestore read successful: ${doc.data()}');
      }
    } catch (e) {
      print('❌ Firestore error: $e');
    }
  }
}