import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get currentUser => _currentUser;

  Future<void> fetchUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _currentUser = UserModel.fromMap(doc.data()!, doc.id);
          notifyListeners();
        }
      }
    } catch (e) {
      // Handle error (e.g., log it)
      log('Error fetching user profile: $e');
    }
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update(updatedUser.toMap());
        _currentUser = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      // Handle error (e.g., log it)
      log('Error updating user profile: $e');
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
