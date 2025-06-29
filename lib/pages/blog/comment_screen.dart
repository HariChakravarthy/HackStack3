import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:my_blog_app/services/comment_service.dart';
import 'package:my_blog_app/services/user_service.dart';
import 'package:my_blog_app/models/comment_model.dart';
import 'package:my_blog_app/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommentScreen extends StatefulWidget {
  final String blogId;
  final String blogAuthorId;

  const CommentScreen({
    Key? key,
    required this.blogId,
    required this.blogAuthorId,
  }) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController commentController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  void _postComment() async {
    if (commentController.text.trim().isEmpty) return;

    await CommentService().addComment(widget.blogId, {
      'commenterName': FirebaseAuth.instance.currentUser!.displayName ?? 'Anonymous',
      'content': commentController.text.trim(),
    });

    commentController.clear();
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await UserService().getUserProfile(userId);
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Widget buildCommentTile(DocumentSnapshot doc) {
    final comment = CommentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    return FutureBuilder<UserModel?>(
      future: getUser(comment.commenterId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final user = snapshot.data!;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: user.profilePicUrl.isNotEmpty
                    ? CachedNetworkImageProvider(user.profilePicUrl)
                    : const AssetImage('lib/images/default_profile.png') as ImageProvider,
                radius: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      "${user.followers.length} followers • ${user.following.length} following",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(comment.content),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy • hh:mm a').format(comment.timestamp),
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        if (uid == comment.commenterId)
                          IconButton(
                            onPressed: () async {
                              await CommentService().deleteComment(widget.blogId, comment.commentId);
                            },
                            icon: const Icon(Icons.delete, size: 18, color: Colors.blueGrey),
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E8DC),
      appBar: AppBar(
        title: const Text(
            "Comments",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: CommentService().getComments(widget.blogId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final commentDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: commentDocs.length,
                  itemBuilder: (context, index) => buildCommentTile(commentDocs[index]),
                );
              },
            ),
          ),
          Divider(thickness: 1,color: Colors.blue[900]),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true ,
                      hintText: "Write a comment... ",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                  TextButton(
                    onPressed: _postComment,
                        style: TextButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            minimumSize: Size(80, 20),
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                              ),
                              ),
                              child: Text(
                            'Post',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                            )
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

