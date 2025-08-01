import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_blog_app/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Create or update user on signup
  Future<void> createUserProfile(Map<String, dynamic> userData) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(userData);
  }

  // One-time fetch
  Future<UserModel?> getUserProfileOnce(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    } else {
      return null;
    }
  }

  // Real-time stream
  Stream<UserModel?> getUserProfileStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      } else {
        return null;
      }
    });
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> updatedData) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update(updatedData);
  }

  // to Follow a user and get updates regarding the list
  Future<void> followUser(String targetUserId) async {
    final userRef = _firestore
        .collection('users')
        .doc(uid);
    final targetRef = _firestore
        .collection('users')
        .doc(targetUserId);

    await userRef.set({
      'following': FieldValue.arrayUnion([targetUserId])
    }, SetOptions(merge: true));

    await targetRef.set({
      'followers': FieldValue.arrayUnion([uid])
    }, SetOptions(merge: true));
  }

  // to unFollow a user and get updates regarding the list
  Future<void> unfollowUser(String targetUserId) async {
    final userRef = _firestore
        .collection('users')
        .doc(uid);
    final targetRef = _firestore
        .collection('users')
        .doc(targetUserId);

    await userRef.set({
      'following': FieldValue.arrayRemove([targetUserId])
    }, SetOptions(merge: true));

    await targetRef.set({
      'followers': FieldValue.arrayRemove([uid])
    }, SetOptions(merge: true));
  }


  /// Get all users to execute search function
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore
        .collection('users')
        .snapshots();
  }

  Future<List<String>> getUserBookmarks() async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    return List<String>.from(data?['bookmarks'] ?? []);
  }

}

// Get followers UIDs to check the list of followers
/*Future<List<String>> getFollowersUIDs([String? userId]) async {
    final String id = userId ?? uid;
    final doc = await _firestore
        .collection('users')
        .doc(id)
        .get();
    return List<String>.from(doc['followers'] ?? []);
  }*/

/*
/// Get following UIDs to check the list of following
  Future<List<String>> getFollowingUIDs([String? userId]) async {
    final String id = userId ?? uid;  // use current user's uid if none provided
    final doc = await _firestore
        .collection('users')
        .doc(id)
        .get();
    return List<String>.from(doc['following'] ?? []);
  }
 */

/*Stream<List<String>> getUserBookmarksStream() {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (snapshot) {
        return List<String>.from(snapshot.data()?['bookmarks'] ?? []);
      },
    );
  }*/