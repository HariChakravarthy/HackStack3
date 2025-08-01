import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_blog_app/models/user_model.dart';
import 'package:my_blog_app/models/blog_model.dart';
import 'package:my_blog_app/services/user_service.dart';
import 'package:my_blog_app/services/blog_service.dart';
import 'package:my_blog_app/pages/blog/blog_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FollowingScreen extends StatefulWidget {
  final String userId;

  const FollowingScreen({super.key, required this.userId});

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
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


    Future<void> toggleFollow(bool isCurrentlyFollowing) async {
    if (isCurrentlyFollowing) {
      await UserService().unfollowUser(widget.userId);
    } else {
      await UserService().followUser(widget.userId);
    }
  }

  String getFollowStatusText(UserModel currentUser, UserModel viewedUser) {
    if (widget.userId == currentUserId) {
      return viewedUser.email;
    } else {
      final isFollowing = currentUser.following.contains(widget.userId);
      final isFollowedByTarget = viewedUser.following.contains(currentUserId);

      if (isFollowing && isFollowedByTarget) {
        return "You both follow each other";
      } else if (isFollowing) {
        return "You follow this user";
      } else if (isFollowedByTarget) {
        return "This user follows you";
      } else {
        return "";
      }
    }
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
                        fontWeight: FontWeight.bold
                    )),
                Text(
                    "2",
                    style: TextStyle(
                        color: Colors.yellow[700],
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    )),
                Text(
                    "blogs",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    )),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<UserModel?>(
        stream: UserService().getUserProfileStream(widget.userId),
        builder: (context, viewedUserSnapshot) {
          if (viewedUserSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewedUserSnapshot.hasError) {
            return Center(child: Text("Error: ${viewedUserSnapshot.error}"));
          }
          if (!viewedUserSnapshot.hasData) {
            return const Center(child: Text("No user data found."));
          }

          final viewedUser = viewedUserSnapshot.data!;

          return StreamBuilder<UserModel?>(
            stream: UserService().getUserProfileStream(currentUserId),
            builder: (context, currentUserSnapshot) {
              if (currentUserSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!currentUserSnapshot.hasData) {
                return const Center(child: Text("No current user data."));
              }

              final currentUser = currentUserSnapshot.data!;
              final isFollowing = currentUser.following.contains(widget.userId);

              return FutureBuilder<List<BlogModel>>(
                future: getUserBlogs(viewedUser.blogs),
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
                                backgroundImage: viewedUser.profilePicUrl.isNotEmpty
                                    ? CachedNetworkImageProvider(viewedUser.profilePicUrl)
                                    : const AssetImage('lib/images/default_profile.jpg') as ImageProvider,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(viewedUser.username,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    getFollowStatusText(currentUser, viewedUser),
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                  )
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(children: [
                                Text(viewedUser.followers.length.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Text("Followers")
                              ]),
                              Column(children: [
                                Text(viewedUser.following.length.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Text("Following")
                              ]),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (widget.userId != currentUserId)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () => toggleFollow(isFollowing),
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue[900],
                                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    isFollowing ? 'Unfollow' : 'Follow',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue[900],
                                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Message', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          const SizedBox(height: 24),
                          const Text("Blogs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          const Divider(height: 2),
                          const SizedBox(height: 10),
                          blogs.isEmpty
                              ? const Text("No blogs found.")
                              : ListView.builder(
                            itemCount: blogs.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              // final blogDoc = blogs[index];
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
          );
        },
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_blog_app/models/user_model.dart';
import 'package:my_blog_app/services/user_service.dart';
import 'package:my_blog_app/services/blog_service.dart';
import 'package:my_blog_app/pages/blog/blog_tile.dart';
import 'package:cached_network_image/cached_network_image.dart';


class FollowingScreen extends StatefulWidget {
  final String userId;

  const FollowingScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _FollowingScreenState createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  late String currentUserId;
  bool isFollowing = false;
  bool isFollowedByTarget = false;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // checkIfFollowingStatus();
  }

  Future<void> checkIfFollowingStatus() async {
    final followingUIDs = await UserService().getFollowingUIDs(currentUserId);
    final followersUIDs = await UserService().getFollowersUIDs(currentUserId);
    setState(() {
      isFollowing = followingUIDs.contains(widget.userId);
      isFollowedByTarget = followersUIDs.contains(widget.userId);
    });
  }

  Future<void> toggleFollow() async {
    setState(() {
      isFollowing = !isFollowing;
    });

    if (isFollowing) {
      await UserService().followUser(widget.userId);
    } else {
      await UserService().unfollowUser(widget.userId);
    }
    checkIfFollowingStatus();
  }

  //successfully used User Service function here

  Future<List<DocumentSnapshot>> getUserBlogs(List<String> blogIds) async {
    final List<DocumentSnapshot> blogs = [];
    for (String id in blogIds) {
      final doc = await BlogService().getBlog(id);
      if (doc.exists) blogs.add(doc);
    }
    return blogs;
  }

  String getFollowStatusText(UserModel user) {
    if (widget.userId == currentUserId) {
      return user.email;
    } else if (isFollowing && isFollowedByTarget) {
      return "You both follow each other";
    } else if (isFollowing) {
      return "You follow this user";
    } else if (isFollowedByTarget) {
      return "This user follows you";
    } else {
      return "";
    }
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
      body:  StreamBuilder<UserModel?>(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.username,
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                getFollowStatusText(user),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              )

                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(children: [
                            Text(
                                user.followers.length.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Text("Followers")
                          ]),
                          Column(children: [
                            Text(
                                user.following.length.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Text("Following")
                          ]),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (widget.userId != currentUserId)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: toggleFollow,
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                isFollowing ? 'Unfollow' : 'Follow',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width:6),
                            TextButton(
                              onPressed: () {
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Message',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      const Text("Blogs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Divider(height: 2),
                      const SizedBox(height: 10),
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
  }
}*/
