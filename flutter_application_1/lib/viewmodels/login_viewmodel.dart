import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      print("Attempting login for $email");
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      print("Firebase Auth success, uid: $uid");

      if (uid != null) {
        final userDoc = await _firestore.collection('users').doc(uid).get();
        print("Firestore doc exists: ${userDoc.exists}");
        if (userDoc.exists) {
          return {
            'uid': uid,
            'email': email,
            'role': userDoc.data()!['role'] ?? 'student',
          };
        }
      }
      print("User doc not found or uid null");
      return null;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }
}
