import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream listening to auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // Register User
  Future<UserCredential?> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String role, // 'Farmer' or 'Owner'
    required String city,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save additional details in Firestore
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'fullName': fullName,
        'email': email,
        'role': role,
        'city': city,
        'phone': '', // Can be completed in Profile edit
        'createdAt': FieldValue.serverTimestamp(),
        'isOnline': false, // For Owners
      });

      return cred;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during registration.');
    }
  }

  // Login User
  Future<UserCredential?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An error occurred during login.');
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
