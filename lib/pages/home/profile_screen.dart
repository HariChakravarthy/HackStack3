import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_blog_app/models/user_model.dart';
import 'package:my_blog_app/models/blog_model.dart';
import 'package:my_blog_app/services/user_service.dart';
import 'package:my_blog_app/services/blog_service.dart';
import 'package:my_blog_app/pages/blog/blog_tile.dart';
import 'package:my_blog_app/pages/home/list_follow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_blog_app/pages/home/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  // const ProfileScreen({Key? key, required this.userId}) : super(key: key);
  const ProfileScreen({super.key, required this.userId});


  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // late Future<UserModel?> userFuture;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<List<BlogModel>> getUserBlogs(List<String> blogIds) async {
    final List<BlogModel> blogs = [];

    for (String id in blogIds) {
      final blog = await BlogService().getBlogOnce(id);
      if (blog != null) {
        blogs.add(blog);
      }
    }
    return blogs;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<UserModel?>(
          stream: UserService().getUserProfileStream(widget.userId),

        builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: \${snapshot.error}"));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("No user data found."));
            }

            final user = snapshot.data!;

            return FutureBuilder<List<BlogModel>>(
              future: getUserBlogs(user.blogs),
              builder: (context, blogSnapshot) {
                if (blogSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final blogs = blogSnapshot.data ?? [];

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: user.profilePicUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(user.profilePicUrl)
                                  : const AssetImage('lib/images/default_profile.jpg') as ImageProvider,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.username,
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold,
                                      ),
                                    overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    softWrap: false,
                                  ),
                                  Text(
                                      user.email,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                                    GestureDetector(
                                         onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ListScreen(
                                                       showFollowers: true, userId: currentUserId// navigate to followers list
                                                    ),
                                                   ),
                                                );
                                              },
                                            child: Column(
                                                    children: [
                                                    Text(
                                                user.followers.length.toString(),
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          const Text("Followers")
                                        ],
                                        ),
                                        ),
                                        const SizedBox(width: 5),
                                        GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                  MaterialPageRoute(
                                                builder: (context) => ListScreen(
                                                showFollowers: false ,userId: currentUserId// navigate to followers list
                                                  ),
                                              ),
                                           );
                                         },
                                      child: Column(
                                    children: [
                                        Text(
                                          user.following.length.toString(),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                            const Text("Following")
                                          ],
                                        ),
                                    ),
                              ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(existingUser: user),
                                  )
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Edit your Profile',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: () {
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Share your Profile',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text("Blogs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                         Divider(thickness: 2, color: Colors.blue[900]),
                        const SizedBox(height: 6),
                        blogs.isEmpty
                            ? const Text("No blogs found.")
                            : ListView.builder(
                          itemCount: blogs.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            // final blogDoc = blogs[index];
                            // final blogId = blogDoc.id;
                            final blog = blogs[index];
                            return Column(
                              children: [
                                BlogTile(blogId: blog.blogId),
                                const SizedBox(height: 10),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                ),
                );
              },
            );
          },
        ),
    );
    // );
  }
}

// Successfully used getUserProfile function here

/*Future<List<DocumentSnapshot>> getUserBlogs(List<String> blogIds) async {
    final List<DocumentSnapshot> blogs = [];
    for (String id in blogIds) {
      final doc = await BlogService().getBlog(id);
      if (doc.exists) blogs.add(doc);
    }
    return blogs;
  }*/

  /*@override
  Widget build(BuildContext context) {
  return SingleChildScrollView(
  // padding: const EdgeInsets.all(8.0),
  child: StreamBuilder<DocumentSnapshot>(

  // stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
  stream: UserService().getUserProfileStream(widget.userId),


  builder: (context, snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(child: CircularProgressIndicator());
  }
  if (snapshot.hasError) {
  return Center(child: Text("Error: \${snapshot.error}"));
  }
  if (!snapshot.hasData) {
  return const Center(child: Text("No user data found."));
  }

  final data = snapshot.data!.data() as Map<String, dynamic>;

  final user = UserModel.fromMap(data);

  return FutureBuilder<List<DocumentSnapshot>>(
  future: getUserBlogs(user.blogs),
  builder: (context, blogSnapshot) {
  if (blogSnapshot.connectionState == ConnectionState.waiting) {
  return const Center(child: CircularProgressIndicator());
  }

  final blogs = blogSnapshot.data ?? [];
  return SingleChildScrollView(
  child: Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Row(
  children: [
  CircleAvatar(
  radius: 30,
  backgroundColor: Colors.grey[200],
  backgroundImage: user.profilePicUrl.isNotEmpty
  ? CachedNetworkImageProvider(user.profilePicUrl)
      : const AssetImage('lib/images/default_profile.jpg') as ImageProvider,
  ),
  const SizedBox(width: 16),
  Expanded(
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(user.username,
  style: const TextStyle(
  fontSize: 18, fontWeight: FontWeight.bold,
  ),
  overflow: TextOverflow.ellipsis,
  maxLines: 1,
  softWrap: false,
  ),
  Text(
  user.email, style: const TextStyle(
  fontSize: 14,
  color: Colors.grey,
  ),
  overflow: TextOverflow.ellipsis,
  maxLines: 1,
  softWrap: false,
  ),
  ],
  ),
  ),
  ],
  ),
  const SizedBox(height: 20),
  Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
  GestureDetector(
  onTap: () {
  Navigator.push(
  context,
  MaterialPageRoute(
  builder: (context) => ListScreen(
  showFollowers: true, // navigate to followers list
  ),
  ),
  );
  },
  child: Column(
  children: [
  Text(
  user.followers.length.toString(),
  style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  const Text("Followers")
  ],
  ),
  ),
  const SizedBox(width: 5),
  GestureDetector(
  onTap: () {
  Navigator.push(
  context,
  MaterialPageRoute(
  builder: (context) => ListScreen(
  showFollowers: false, // navigate to followers list
  ),
  ),
  );
  },
  child: Column(
  children: [
  Text(
  user.following.length.toString(),
  style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  const Text("Following")
  ],
  ),
  ),
  ],
  ),
  const SizedBox(height: 24),
  Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
  TextButton(
  onPressed: () {
  },
  style: TextButton.styleFrom(
  backgroundColor: Colors.blue[900],
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(8),
  ),
  ),
  child: const Text(
  'Edit your Profile',
  style: TextStyle(color: Colors.white),
  ),
  ),
  const SizedBox(width: 4),
  TextButton(
  onPressed: () {
  },
  style: TextButton.styleFrom(
  backgroundColor: Colors.blue[900],
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(8),
  ),
  ),
  child: const Text(
  'Share your Profile',
  style: TextStyle(color: Colors.white),
  ),
  ),
  ],
  ),
  const SizedBox(height: 24),
  const Text("Blogs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  const SizedBox(height: 10),
  Divider(thickness: 2, color: Colors.blue[900]),
  const SizedBox(height: 6),
  blogs.isEmpty
  ? const Text("No blogs found.")
      : ListView.builder(
  itemCount: blogs.length,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemBuilder: (context, index) {
  final blogDoc = blogs[index]; // each DocumentSnapshot
  final blogId = blogDoc.id;
  return Column(
  children: [
  BlogTile(blogId: blogId),
  const SizedBox(height: 10),
  ],
  );
  },
  ),
  ],
  ),
  ),
  );
  },
  );
  },
  ),
  );
  // );
  }
}*/



