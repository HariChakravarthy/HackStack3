import 'package:flutter/material.dart';
import 'package:my_blog_app/services/book_mark_service.dart';
import 'package:my_blog_app/pages/blog/blog_tile.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 6),
                      Text(
                    "Saved",
                        style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                         color: Colors.blue[900],
                      ),
                    ),
                   const SizedBox(height: 12),
                   Divider(thickness: 2, color: Colors.blue[900]),
              const SizedBox(height: 10),
                Expanded(
                 child: StreamBuilder<List<String>>(
          stream: BookmarkService().getUserBookmarksStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            final bookmarkedBlogIds = snapshot.data!;
            if (bookmarkedBlogIds.isEmpty) {
              return const Center(child: Text("No bookmarks yet."));
            }

            return ListView.builder(
              itemCount: bookmarkedBlogIds.length,
              itemBuilder: (context, index) {
                return BlogTile(blogId: bookmarkedBlogIds[index]);
              },
            );
          },
        ),
      ),
        ],
      ),
      );
  }
}
