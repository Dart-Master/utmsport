import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user?.uid;
      if (uid == null) return "Registration failed. Please try again.";

      // Create user document in Firestore
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'role': 'student', // default role
      });

      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }
}
