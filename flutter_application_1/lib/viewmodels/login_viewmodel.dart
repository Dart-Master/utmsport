import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;

      if (uid != null) {
        final userDoc = await _firestore.collection('users').doc(uid).get();

        if (userDoc.exists) {
          return {
            'uid': uid,
            'email': email,
            'role': userDoc.data()!['role'] ?? 'student',
          };
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print("Firebase login error: ${e.message}");
      return null;
    }
  }
}
