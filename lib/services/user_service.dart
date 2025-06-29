import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Create or update user on signup
  Future<void> createUserProfile(Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(uid).set(userData);
  }

  // Get user profile data
  Future<DocumentSnapshot> getUserProfile(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  // to Follow a user and get updates regarding the list
  Future<void> followUser(String targetUserId) async {
    final userRef = _firestore.collection('users').doc(uid);
    final targetRef = _firestore.collection('users').doc(targetUserId);

    await userRef.set({
      'following': FieldValue.arrayUnion([targetUserId])
    }, SetOptions(merge: true));

    await targetRef.set({
      'followers': FieldValue.arrayUnion([uid])
    }, SetOptions(merge: true));
  }

  // to unFollow a user and get updates regarding the list
  Future<void> unfollowUser(String targetUserId) async {
    final userRef = _firestore.collection('users').doc(uid);
    final targetRef = _firestore.collection('users').doc(targetUserId);

    await userRef.set({
      'following': FieldValue.arrayRemove([targetUserId])
    }, SetOptions(merge: true));

    await targetRef.set({
      'followers': FieldValue.arrayRemove([uid])
    }, SetOptions(merge: true));
  }


  /// Get all users to execute search function
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection('users').snapshots();
  }

  /// Get following UIDs to check the list of following
  Future<List<String>> getFollowingUIDs([String? userId]) async {
    final String id = userId ?? uid;  // use current user's uid if none provided
    final doc = await _firestore.collection('users').doc(id).get();
    return List<String>.from(doc['following'] ?? []);
  }

  /// Get followers UIDs to check the list of followers
  Future<List<String>> getFollowersUIDs([String? userId]) async {
    final String id = userId ?? uid;
    final doc = await _firestore.collection('users').doc(id).get();
    return List<String>.from(doc['followers'] ?? []);
  }


}
