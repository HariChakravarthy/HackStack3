import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BlogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Create a new blog post

  Future<void> addBlog(Map<String, dynamic> blogData) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    blogData['authorId'] = uid;
    blogData['timestamp'] = FieldValue.serverTimestamp();

    final blogId = _firestore.collection('blogs').doc().id;
    blogData['blogId'] = blogId;

    //  Add blog to global 'blogs' collection
    await _firestore.collection('blogs').doc(blogId).set(blogData);

    // Update user's document to include blogId
    await _firestore.collection('users').doc(uid).update({
      'blogs': FieldValue.arrayUnion([blogId])
    });
  }


  // to Update a blog post
  Future<void> updateBlog(String blogId, Map<String, dynamic> updatedData) async {
    await _firestore
        .collection('blogs')
        .doc(blogId)
        .update(updatedData);
  }

  // to Delete a blog
  Future<void> deleteBlog(String blogId) async {
    await _firestore
        .collection('blogs')
        .doc(blogId)
        .delete();
  }

  // Get all blogs used for explore screen
  Stream<QuerySnapshot> getAllBlogs() {
    return _firestore
        .collection('blogs')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get blogs of followed users (Following screen)
  Stream<QuerySnapshot> getFollowingBlogs(List<String> followingUIDs) {
    return _firestore
        .collection('blogs')
        .where('authorId', whereIn: followingUIDs)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Toggle like on a blog
  // ensures all logged in users to like the blog
  Future<void> toggleLike(String blogId, bool isLiked) async {
    final docRef = _firestore.collection('blogs').doc(blogId);
    try {
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        throw Exception('Blog not found');
      }

      // Ensure 'likes' is an array
      final data = docSnap.data() as Map<String, dynamic>;
      final likes = List<String>.from(data['likes'] ?? []);

      if (isLiked) {
        await docRef.update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await docRef.update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      // print("toggleLike error: $e");
      rethrow;
    }
  }


  // Get single blog details
  Future<DocumentSnapshot> getBlog(String blogId) async {
    return await _firestore
        .collection('blogs')
        .doc(blogId)
        .get();
  }
}
