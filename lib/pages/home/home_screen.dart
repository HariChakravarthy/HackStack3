import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_blog_app/services/blog_service.dart';
import 'package:my_blog_app/pages/blog/blog_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DocumentSnapshot> allFollowingBlogs = [];
  List<DocumentSnapshot> filteredBlogs = [];

  Stream<QuerySnapshot>? blogsStream;

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
  }

  getOnTheLoad() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    // Get following list from firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    List<String> followingUIDs = List<String>.from(userDoc.get('following') ?? []);

    // Fetch blogs from followed users
    if (followingUIDs.isNotEmpty) {
      blogsStream = BlogService().getFollowingBlogs(followingUIDs);
      blogsStream!.listen((snapshot) {
        allFollowingBlogs = snapshot.docs;
        filteredBlogs = allFollowingBlogs;
        setState(() {});
      });
    } else {
      setState(() {
        allFollowingBlogs = [];
        filteredBlogs = [];
      });
    }
  }

  Widget allFollowedBlogs() {
    return filteredBlogs.isEmpty
        ? const Center(child: Text("No Blogs found"))
        : ListView.builder(
      itemCount: filteredBlogs.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Column(
          children: [
            BlogTile(blogId : filteredBlogs[index].id),
            const SizedBox(height: 10), // Add spacing below each blog tile
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(height: 4),
              Text(
                "Home ",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900],
                fontSize: 25),
              ),
              const SizedBox(height: 12),
              Divider(thickness: 2, color: Colors.blue[900]),
              const SizedBox(height: 12),
              allFollowedBlogs(),
            ],
          ),
        );
  }
}
