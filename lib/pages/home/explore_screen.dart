import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_blog_app/services/blog_service.dart';
import 'package:my_blog_app/services/user_service.dart';
import 'package:my_blog_app/pages/blog/blog_tile.dart';
import 'package:my_blog_app/components/profile_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'News',
    'Politics',
    'Business',
    'Movies',
    'Cricket',
    'Technology',
    'Economics',
    'other',
  ];

  List<DocumentSnapshot> allExploreBlogs = [];
  List<DocumentSnapshot> filteredBlogs = [];
  List<DocumentSnapshot> allUsers = [];
  List<DocumentSnapshot> filteredUsers = [];

  Stream<QuerySnapshot>? blogsStream;
  Stream<QuerySnapshot>? usersStream;
  String searchQuery = ''; // why is this used ?

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
  }

  getOnTheLoad() async {
    blogsStream = BlogService().getAllBlogs();
    blogsStream!.listen((snapshot) {
      allExploreBlogs = snapshot.docs;
      filteredBlogs = allExploreBlogs;
      setState(() {});
    });

    // Fetch users
    /*final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    allUsers = usersSnapshot.docs;
    filteredUsers = allUsers;
    setState(() {});*/

    usersStream = UserService().getAllUsers();
    usersStream!.listen((snapshot) {
      allUsers = snapshot.docs;
      filteredUsers = allUsers;
      setState(() {});
    });
  }

  void searchBlogAndAuthor(String query) {
    query = query.toLowerCase();
    searchQuery = query;
    setState(() {
      filteredBlogs =
          allExploreBlogs.where((doc) {
            String author = (doc["authorName"] ?? '').toLowerCase();
            String title = (doc["title"] ?? '').toLowerCase();
            String category = (doc["category"] ?? '').toLowerCase();

            bool matchesSearch =
                author.contains(query) ||
                title.contains(query) ||
                category.contains(query);
            bool matchesCategory =
                selectedCategory == 'All' ||
                category == selectedCategory.toLowerCase();
            return matchesSearch && matchesCategory;
          }).toList();

      filteredUsers =
          allUsers.where((doc) {
            String username = (doc["username"] ?? '').toLowerCase();
            return username.contains(query);
          }).toList();
    });
  }

  Widget allUsersResult() {
    return filteredUsers.isEmpty
        ? const Center(child: Text("No Users found"))
        : ListView.builder(
          itemCount: filteredUsers.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final userDoc = filteredUsers[index];
            return ProfileTile(userId: userDoc.id);
          },
        );
  }

  Widget allExploredBlogs() {
    return filteredBlogs.isEmpty
        ? const Center(child: Text("No Blogs found"))
        : ListView.builder(
          itemCount: filteredBlogs.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
              children: [
                BlogTile(blogId: filteredBlogs[index].id),
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
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 4),
            Text(
              "Explore",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 12),
            Material(
              elevation: 2,
              shadowColor: Colors.white60,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardColor,
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: searchBlogAndAuthor,
                  decoration: InputDecoration(
                    labelText: 'Wanna find something?',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed:
                          () => searchBlogAndAuthor(searchController.text),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ), // when is material used ?

            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Row(
                children:
                    categories.map((category) {
                      final isSelected = selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            category[0].toUpperCase() + category.substring(1),
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedCategory = category;
                            });
                            searchBlogAndAuthor(searchController.text);
                          },
                          selectedColor: Colors.yellow[700],
                          backgroundColor: Colors.blue[900],
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Divider(thickness: 2, color: Colors.blue[900]),
            const SizedBox(height: 10),
            if (searchQuery.isNotEmpty) allUsersResult(),
            const SizedBox(height: 16),
            allExploredBlogs(),
          ],
        ),
      ),
    );
  }
}

/*
usersStream = await UserService.getAllUsers();
    usersStream!.listen((snapshot) {
      allUsers = usersSnapshot.docs;
      filteredUsers = allUsers;
      setState(() {});
    });
 */
