import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Sign up with email and password
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Create user
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // SKIP EMAIL VERIFICATION FOR NOW
      // TODO: Re-enable when email is configured properly
      // await result.user!.sendEmailVerification();

      // Create user document in Firestore
      final appUser = AppUser(
        id: result.user!.uid,
        email: email,
        username: username,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(appUser.toMap());

      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists for that email';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid';
      }
      return e.message ?? 'An error occurred during sign up';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // Success - NO EMAIL CHECK
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid';
      } else if (e.code == 'invalid-credential') {
        return 'Invalid email or password';
      }
      return e.message ?? 'An error occurred during sign in';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Reset password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email';
      }
      return e.message ?? 'Failed to send password reset email';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Delete account
  Future<String?> deleteAccount() async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).delete();
      await _auth.currentUser!.delete();
      return null;
    } catch (e) {
      return 'Failed to delete account: $e';
    }
  }
}