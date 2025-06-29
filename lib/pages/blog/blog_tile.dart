import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:my_blog_app/components/follow_button.dart';
import 'package:my_blog_app/pages/blog/blog_detail_screen.dart';
import 'package:my_blog_app/pages/home/following_screen.dart';
import 'package:my_blog_app/services/blog_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_blog_app/models/blog_model.dart';
import 'package:my_blog_app/pages/blog/edit_blog_screen.dart';
import 'package:my_blog_app/services/book_mark_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Creating blog tile to show display the blogs

class BlogTile extends StatefulWidget {
  final String blogId; // reference to show the respective tile in screens

  const BlogTile({Key? key, required this.blogId}) : super(key: key);

  @override
  State<BlogTile> createState() => _BlogTileState();
}

class _BlogTileState extends State<BlogTile> {
  bool isBookmarked = false;

  final Map<String, IconData> _categoryIcons = {
    'News': Icons.newspaper,
    'Politics': Icons.how_to_vote,
    'Business': Icons.business_center,
    'Movies': Icons.movie,
    'Cricket': Icons.sports_cricket,
    'Technology': Icons.devices,
    'Economics': Icons.bar_chart,
    'other': Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    _loadBookmarkStatus();
  }

  Future<void> _loadBookmarkStatus() async {
    final bookmarks = await BookmarkService().getUserBookmarks();
    setState(() {
      isBookmarked = bookmarks.contains(widget.blogId);
    });
  }

  void toggleBookmark() async {
    await BookmarkService().toggleBookmark(widget.blogId, isBookmarked);
    setState(() {
      isBookmarked = !isBookmarked;
    });
  }

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
    return StreamBuilder<DocumentSnapshot>(  // To display the created blogs from the firestore
      stream: FirebaseFirestore.instance.collection('blogs').doc(widget.blogId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(); // Return loading or empty state
        }
        // Display the time and date the blog has been created
        final blog = snapshot.data!;
        final currentUserId = FirebaseAuth.instance.currentUser!.uid;
        final isOwner = blog['authorId'] == currentUserId;
        Timestamp? timestamp = blog["timestamp"];
        DateTime? createdAt = timestamp?.toDate();
        String formattedDate = createdAt != null
            ? DateFormat('MMM d, yyyy • hh:mm a').format(createdAt)
            : 'Unknown Date';
        // To get into the full details of the blog
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlogDetailScreen(blogId: blog['blogId']),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FollowingScreen(userId: blog['authorId']),
                          ),
                        );
                      },
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(blog['authorId']).get(),
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
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FollowingScreen(userId: blog['authorId']),
                          ),
                        );
                      },
                      child: Text(
                        blog['authorName'],
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    FollowButton(authorId: blog['authorId']),
                    Expanded(
                      child : IconButton(
                            onPressed: () {
                            },
                            icon: const Icon(
                                Icons.more_vert,
                              color: Colors.blueGrey,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  blog["title"] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  blog['content'] != null
                      ? (blog['content'] as String).substring(
                      0, blog['content'].length > 60 ? 60 : blog['content'].length)
                      : '',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      _categoryIcons[blog["category"]] ?? Icons.category,
                      size: 18,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      blog["category"] ?? '',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                        Icons.favorite_border,
                      size: 18,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(blog["likes"].length.toString()),
                    const SizedBox(width: 12),
                    const Icon(
                        Icons.comment,
                      size: 18,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 4),
                    StreamBuilder<int>(
                      stream: getCommentCount(widget.blogId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text("0");
                        return Text("${snapshot.data}");
                      },
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                        Icons.share,
                      size: 18,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(blog["shares"].length.toString()),
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Colors.blueGrey : Colors.blueGrey,
                      ),
                      onPressed: toggleBookmark,
                    ),
                    const SizedBox(width: 4),
                    if(isOwner)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditBlogScreen(
                                    existingBlog: BlogModel(
                                      blogId: blog.id,
                                      title: blog['title'],
                                      content: blog['content'],
                                      authorId : blog['authorId'],
                                      authorName : blog['authorName'],
                                      category : blog['category'],
                                      timestamp : createdAt!,
                                      likes: List<String>.from(blog['likes'] ?? []),
                                      comments: List<String>.from(blog['comments'] ?? []),
                                      shares: List<String>.from(blog['shares'] ?? []),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              margin: const EdgeInsets.only(right : 8, top : 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder : (context) => AlertDialog(
                                  title: const Text("Delete Blog"),
                                  content: const Text("Are you sure you want to delete this blog ? "),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text(
                                          "cancel"
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Delete", style : TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if(confirm == true) {
                                await BlogService().deleteBlog(blog.id);

                                Fluttertoast.showToast(msg: "Blog deleted");

                                // Optionally remove the blogId from user document
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUserId)
                                    .update({
                                  'blogs': FieldValue.arrayRemove([blog.id])
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.white, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
