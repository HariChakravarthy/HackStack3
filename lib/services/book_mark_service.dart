/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // to add the blog in bookmarks
  Future<void> toggleBookmark(String blogId, bool isBookmarked) async {
    final userDoc = _firestore.collection('users').doc(uid);

    await userDoc.update({
      'bookmarks': isBookmarked
          ? FieldValue.arrayRemove([blogId])
          : FieldValue.arrayUnion([blogId])
    });
  }

  // to store the ids of the blog and display them in book_mark screen
  Future<List<String>> getUserBookmarks() async {
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    return List<String>.from(data?['bookmarks'] ?? []);
  }

  Stream<List<String>> getUserBookmarksStream() {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (snapshot) {
        return List<String>.from(snapshot.data()?['bookmarks'] ?? []);
      },
    );
  }
}*/
