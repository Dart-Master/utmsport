import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://dartmaster-ffc0b.appspot.com',  // Your Firebase Storage bucket URL
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _profileImageUrl;
  String? _headerImageUrl;
  String? _name;
  String? _aboutMe;
  String? _education;
  String? _phone;

  String? get profileImageUrl => _profileImageUrl;
  String? get headerImageUrl => _headerImageUrl;
  String? get name => _name;
  String? get aboutMe => _aboutMe;
  String? get education => _education;
  String? get phone => _phone;

  /// Initializes the user data
  Future<void> initialize() async {
    await fetchUserData();
  }

  /// Fetch user data from Firestore and Storage
  Future<void> fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          _name = data?['name'];
          _aboutMe = data?['aboutMe'];
          _education = data?['education'];
          _phone = data?['phone'];
          _profileImageUrl = data?['profileImageUrl'];
          _headerImageUrl = data?['headerImageUrl'];

          // Fallback to Storage if missing
          if (_profileImageUrl == null) {
            try {
              _profileImageUrl = await _storage
                  .ref('profile_images/${user.uid}')
                  .getDownloadURL();
            } catch (_) {}
          }
          if (_headerImageUrl == null) {
            try {
              _headerImageUrl = await _storage
                  .ref('header_images/${user.uid}')
                  .getDownloadURL();
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  /// Update profile fields in Firestore
  Future<void> updateProfile({
    String? name,
    String? aboutMe,
    String? education,
    String? phone,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name ?? _name,
          'aboutMe': aboutMe ?? _aboutMe,
          'education': education ?? _education,
          'phone': phone ?? _phone,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Update local variables
        _name = name ?? _name;
        _aboutMe = aboutMe ?? _aboutMe;
        _education = education ?? _education;
        _phone = phone ?? _phone;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  /// Upload profile image to Firebase Storage and update Firestore
  Future<void> uploadProfileImage(File pickedFile) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final ref = _storage.ref('profile_images/${user.uid}');
        await ref.putFile(pickedFile); // Upload the file
        _profileImageUrl = await ref.getDownloadURL(); // Get the URL of the uploaded image

        await _firestore.collection('users').doc(user.uid).set({
          'profileImageUrl': _profileImageUrl,  // Store the URL in Firestore
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error uploading profile image: $e');
        rethrow;
      }
    }
  }

  /// Upload header image to Firebase Storage and update Firestore
  Future<void> uploadHeaderImage(File pickedFile) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final ref = _storage.ref('header_images/${user.uid}');
        await ref.putFile(pickedFile); // Upload the header image
        _headerImageUrl = await ref.getDownloadURL(); // Get the URL of the uploaded image

        await _firestore.collection('users').doc(user.uid).set({
          'headerImageUrl': _headerImageUrl,  // Store the URL in Firestore
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error uploading header image: $e');
        rethrow;
      }
    }
  }

  /// Function to pick an image using the `image_picker` package
  Future<void> pickImage({required String imageType}) async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      
      if (imageType == 'profile') {
        await uploadProfileImage(file);
      } else {
        await uploadHeaderImage(file);
      }
    }
  }
}
