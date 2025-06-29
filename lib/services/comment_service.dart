import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // Add a comment to a blog
  Future<void> addComment(String blogId, Map<String, dynamic> commentData) async {
    commentData['commenterId'] = uid;
    commentData['timestamp'] = FieldValue.serverTimestamp();
    await _firestore
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .add(commentData);
  }

  // Delete a comment
  Future<void> deleteComment(String blogId, String commentId) async {
    await _firestore
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  // Get comments for a specific blog to see the real time update
  Stream<QuerySnapshot> getComments(String blogId) {
    return _firestore
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
