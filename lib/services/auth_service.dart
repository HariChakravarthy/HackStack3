import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Optional: force account picker
      await GoogleSignIn().signOut();

      // Start Google sign-in
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) return null;

      // Get auth details
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        final uid = user.uid;
        final userDoc = await _firestore.collection('users').doc(uid).get();

        // Create new user document in Firestore
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(uid).set({
            'uid': uid,
            'username': user.displayName ?? 'Anonymous',
            'email': user.email ?? '',
            'profilePicUrl': user.photoURL ?? '',
            'followers': [],
            'following': [],
            'blogs': [],
          });
        }
      }

      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }
}




