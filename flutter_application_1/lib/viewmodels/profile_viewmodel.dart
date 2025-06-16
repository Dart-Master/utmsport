import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ProfileViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _profileImageUrl;
  String? _headerImageUrl;
  String? _name;
  String? _aboutMe;
  String? _education;
  String? _linkedInUrl;
  String? _githubUrl;

  String? get profileImageUrl => _profileImageUrl;
  String? get headerImageUrl => _headerImageUrl;
  String? get name => _name;
  String? get aboutMe => _aboutMe;
  String? get education => _education;
  String? get linkedInUrl => _linkedInUrl;
  String? get githubUrl => _githubUrl;

  Future<void> initialize() async {
    await fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        
        if (doc.exists) {
          _name = doc.data()?['name'];
          _aboutMe = doc.data()?['aboutMe'];
          _education = doc.data()?['education'];
          _linkedInUrl = doc.data()?['linkedInUrl'];
          _githubUrl = doc.data()?['githubUrl'];
          _profileImageUrl = doc.data()?['profileImageUrl'];
          _headerImageUrl = doc.data()?['headerImageUrl'];
          
          // Legacy support for images stored in Storage
          try {
            if (_profileImageUrl == null) {
              _profileImageUrl = await _storage
                  .ref('profile_images/${user.uid}')
                  .getDownloadURL();
            }
            if (_headerImageUrl == null) {
              _headerImageUrl = await _storage
                  .ref('header_images/${user.uid}')
                  .getDownloadURL();
            }
          } catch (e) {
            debugPrint('Error fetching images from storage: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? aboutMe,
    String? education,
    String? linkedInUrl,
    String? githubUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name ?? _name,
          'aboutMe': aboutMe ?? _aboutMe,
          'education': education ?? _education,
          'linkedInUrl': linkedInUrl ?? _linkedInUrl,
          'githubUrl': githubUrl ?? _githubUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        _name = name ?? _name;
        _aboutMe = aboutMe ?? _aboutMe;
        _education = education ?? _education;
        _linkedInUrl = linkedInUrl ?? _linkedInUrl;
        _githubUrl = githubUrl ?? _githubUrl;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> uploadProfileImage(String filePath) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final ref = _storage.ref('profile_images/${user.uid}');
        await ref.putFile(File(filePath));
        _profileImageUrl = await ref.getDownloadURL();
        
        await _firestore.collection('users').doc(user.uid).set({
          'profileImageUrl': _profileImageUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      rethrow;
    }
  }

  Future<void> uploadHeaderImage(String filePath) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final ref = _storage.ref('header_images/${user.uid}');
        await ref.putFile(File(filePath));
        _headerImageUrl = await ref.getDownloadURL();
        
        await _firestore.collection('users').doc(user.uid).set({
          'headerImageUrl': _headerImageUrl,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error uploading header image: $e');
      rethrow;
    }
  }
}