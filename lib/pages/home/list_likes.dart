import 'package:flutter/material.dart';
import 'package:my_blog_app/services/blog_service.dart';
import 'package:my_blog_app/components/profile_tile.dart';
import 'package:my_blog_app/models/blog_model.dart';

class ListLikes extends StatelessWidget {
  final String blogId;

  const ListLikes({super.key, required this.blogId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8DC),
      appBar : AppBar(
        title: Text(
          "Liked By",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
      body: FutureBuilder<BlogModel?>(
        future: BlogService().getBlogOnce(blogId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final blog = snapshot.data;
          if (blog == null || blog.likes.isEmpty) {
            return const Center(child: Text("No likes yet"));
          }

          final likers = blog.likes; // This is a List<String> of UIDs

          return ListView.builder(
            itemCount: likers.length,
            itemBuilder: (context, index) {
              return ProfileTile(userId: likers[index]);
            },
          );
        },
      ),
    );
  }
}
