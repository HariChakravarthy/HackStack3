import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_blog_app/pages/home/following_screen.dart';
import 'package:my_blog_app/pages/blog/comment_screen.dart';
import 'package:my_blog_app/components/follow_button.dart';
import 'package:my_blog_app/services/blog_service.dart';
import 'package:my_blog_app/services/user_service.dart';
import 'package:my_blog_app/models/blog_model.dart';
import 'package:my_blog_app/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_blog_app/pages/home/list_likes.dart';

class BlogDetailScreen extends StatefulWidget {
  final String blogId;

  const BlogDetailScreen({super.key, required this.blogId});

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<int> getCommentCount(String blogId) {
    return FirebaseFirestore.instance
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xFFE8E8DC),
      appBar: AppBar(
        title: Column(
          children: [
            Row(
              children: [
                Text(
                  "way",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "2",
                  style: TextStyle(
                    color: Colors.yellow[700],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "blogs",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24 ,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<BlogModel?>(

        stream : BlogService().getBlogStream(widget.blogId),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Blog not found"));
          }

          final blog = snapshot.data!;

          // final likes = blog.likes ?? [];
          final isLiked = blog.likes.contains(uid);

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(blog.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FollowingScreen(userId: blog.authorId),
                          ),
                        );
                      },
                      child: FutureBuilder<UserModel?>(

                        future: UserService().getUserProfileOnce(blog.authorId),

                        builder: (context, userSnapshot) {

                          if (!userSnapshot.hasData || userSnapshot.data == null) {
                            return const CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white, size: 15),
                            );
                          }

                          final user = userSnapshot.data!;
                          // final profilePicUrl = user.profilePicUrl ?? '';
                          final profilePicUrl = userSnapshot.data!.profilePicUrl ?? '';

                          return CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: profilePicUrl.isNotEmpty
                                ? CachedNetworkImageProvider(profilePicUrl)
                                : const AssetImage('lib/images/default_profile.png') as ImageProvider,

                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FollowingScreen(userId: blog.authorId),
                          ),
                        );
                      },
                      child: Text(blog.authorName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    FollowButton(authorId: blog.authorId),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(child: Text(blog.content)),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                      onPressed: () async {
                        try {
                          await BlogService().toggleLike(widget.blogId, isLiked);
                          Fluttertoast.showToast(
                            msg: isLiked ? "Unliked" : "Liked",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.blueGrey,
                            textColor: Colors.white,
                            fontSize: 14.0,
                          );
                        } catch (e) {
                          Fluttertoast.showToast(
                            msg: "Failed to like/unlike post",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.blueGrey,
                            textColor: Colors.white,
                            fontSize: 14.0,
                          );
                          print("Error toggling like: $e");
                        }
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListLikes(blogId: blog.blogId),
                          ),
                        );
                      },
                    child : Text("${blog.likes.length ?? 0}"),
                    ),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentScreen(
                              blogId: blog.blogId,
                              blogAuthorId: blog.authorId,
                            ),
                          ),
                        );
                      },
                    ),
                    StreamBuilder<int>(
                      stream: getCommentCount(widget.blogId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text("0");
                        return Text("${snapshot.data}");
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {},
                    ),
                    Text("0"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



/*@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E8DC),
      appBar: AppBar(
        title: Column(
          children: [
            Row(
              children: [
                Text(
                  "way",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "2",
                  style: TextStyle(
                    color: Colors.yellow[700],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "blogs",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24 ,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blogs')
            .doc(widget.blogId)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final doc = snap.data!;
          final likes = List.from(doc['likes'] ?? []);
          final isLiked = likes.contains(uid);

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FollowingScreen(userId: doc['authorId']),
                          ),
                        );
                      },
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(doc['authorId']).get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white, size: 15),
                            );
                          }
                          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                          final profilePicUrl = userData['profilePicUrl'] ?? '';

                          return CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: profilePicUrl.isNotEmpty
                                ? CachedNetworkImageProvider(profilePicUrl)
                                : const AssetImage('lib/images/default_profile.png') as ImageProvider,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FollowingScreen(userId: doc['authorId']),
                          ),
                        );
                      },
                      child: Text("${doc['authorName']}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    FollowButton(authorId: doc['authorId']),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(child: Text(doc['content'])),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                      onPressed: () async {
                        try {
                          await BlogService().toggleLike(widget.blogId, isLiked);
                          Fluttertoast.showToast(
                              msg: isLiked ? "Unliked" : "Liked",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.blueGrey,
                            textColor: Colors.white,
                            fontSize: 14.0,
                          );
                        } catch (e) {
                          Fluttertoast.showToast(
                              msg: "Failed to like/unlike post",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.blueGrey,
                            textColor: Colors.white,
                            fontSize: 14.0,
                          );
                          print("Error toggling like: $e");
                        }
                      },
                    ),
                    Text("${likes.length}"),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentScreen(
                              blogId: doc.id,
                              blogAuthorId: doc['authorId'],
                            ),
                          ),
                        );
                      },
                    ),
                    StreamBuilder<int>(
                      stream: getCommentCount(widget.blogId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text("0");
                        return Text("${snapshot.data}");
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {},
                    ),
                    Text("0"),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}*/

