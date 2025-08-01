import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Create a service class to handle authentication logic
class AuthService {
  // Create a Firestore instance for later use
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Main function to sign in using Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Force account picker every time by signing out any previously signed-in account
      await GoogleSignIn().signOut();

      // Trigger the Google sign-in flow
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // If the user closes the sign-in popup or cancels, return null
      if (gUser == null) return null;

      // Get the authentication tokens from the Google account
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Use those tokens to create a Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      // Sign in to Firebase using the Google credential
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Get the currently signed-in user from the userCredential
      final user = userCredential.user;

      // If user is successfully signed in
      if (user != null) {
        final uid = user.uid;

        // Check if a Firestore document for this user already exists
        final userDoc = await _firestore.collection('users').doc(uid).get();

        // If the user is signing in for the first time (document doesn't exist)
        if (!userDoc.exists) {
          // Create a new user document with default fields
          await _firestore.collection('users').doc(uid).set({
            'uid': uid,
            'username': user.displayName ?? 'Anonymous',   // User's name
            'email': user.email ?? '',                     // User's email
            'profilePicUrl': user.photoURL ?? '',          // Google profile pic
            'followers': [],                               // Initially empty
            'following': [],                               // Initially empty
            'blogs': [],                                   // Blog IDs (if any)
          });
        }
      }
      // Return the UserCredential object to the caller
      return userCredential;
    } catch (e) {
      // Print error for debugging
      print('Google Sign-In Error: $e');

      // Return null if something went wrong
      return null;
    }
  }
}



