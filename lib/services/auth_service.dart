import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await GoogleSignIn().signOut(); // Optional: force picker
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) return null;

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        final userDoc =
        await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // If new user, create profile
          await _firestore.collection('users').doc(user.uid).set({
            'uid': uid,
            'username': user.displayName ?? 'Anonymous',
            'email': user.email ?? '',
            'profilePicUrl': user.photoURL ?? '',
            'followers': [],
            'following': [],
            'blogs': [],

          });
        }
        print("New Google user created: ${user.displayName}, ${user.email}");
      }

      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }
}



