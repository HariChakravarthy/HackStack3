import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_blog_app/pages/home/profile_screen.dart';
import 'package:my_blog_app/pages/home/home_screen.dart';
import 'package:my_blog_app/pages/home/explore_screen.dart';
import 'package:my_blog_app/pages/blog/create_blog_screen.dart';
import 'package:my_blog_app/pages/home/book_mark_screen.dart';
import 'package:my_blog_app/pages/auth/login_or_register.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  late final List<Widget> screens;
  late final String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    screens = [
      const HomeScreen(),
      const SearchScreen(),
      const CreateBlogScreen(),
      const BookmarkScreen(),
      ProfileScreen(userId: uid),
    ];
  }

  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8DC),
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'lib/images/logo.jpg',
            width: 45,
            height: 45,
            fit: BoxFit.contain,
          ),
        ),
        title: Row(
          children: [
            const Text("way", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text("2", style: TextStyle(color: Colors.yellow[700], fontSize: 24, fontWeight: FontWeight.bold)),
            const Text("blogs", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: getAppBarActions(currentIndex),
      ),
      body: SafeArea(child: screens[currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  List<Widget> getAppBarActions(int index) {
    // You can customize actions for different screens here
    switch (index) {
      case 0: // Home
        return [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {} ,
          ),
          IconButton(
            icon: const Icon(
              Icons.chat,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {} ,
          ),
          const SizedBox(width: 4),
        ];
      case 1: // Search
        return [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ];
      case 2: // Search
        return [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ];
      case 3: // Search
        return [
          IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ];
      case 4: // Search
        return [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {} ,
          ),
          IconButton(
            icon: const Icon(
              Icons.logout_outlined,
              color: Colors.white,
              size: 25,
            ),
            onPressed:
              signUserOut
          ),
          const SizedBox(width: 4),
        ];
      default:
        return [];
    }
  }
}



