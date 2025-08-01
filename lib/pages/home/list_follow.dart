import 'package:flutter/material.dart';
import 'package:my_blog_app/services/user_service.dart';
import 'package:my_blog_app/components/profile_tile.dart';
import 'package:my_blog_app/models/user_model.dart';

class ListScreen extends StatelessWidget {
  final bool showFollowers; // true: show followers, false: show following
  final String userId;

  const ListScreen({super.key, required this.showFollowers, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8DC),
      appBar: AppBar(
        title: Text(
          showFollowers ? 'Followers' : 'Following',
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
      body: FutureBuilder<UserModel?>(
        future: UserService().getUserProfileOnce(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;

          if (user == null || user.followers.isEmpty ) {
            return const Center(child: Text("No Followers yet"));
          }

          if (user.following.isEmpty ) {
            return const Center(child: Text("No Following yet"));
          }

          final followers = user.followers;
          final following = user.following; // This is a List<String> of UIDs

          return ListView.builder(
            itemCount: showFollowers ? followers.length : following.length,
            itemBuilder: (context, index) {
              return ProfileTile(userId: showFollowers ? followers[index] : following[index]);
            },
          );
        },
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:my_blog_app/models/user_model.dart';
import 'package:my_blog_app/services/user_service.dart';
import 'package:my_blog_app/components/profile_tile.dart';

class ListScreen extends StatelessWidget {
  final bool showFollowers; // true: show followers, false: show following

  const ListScreen({Key? key, required this.showFollowers}) : super(key: key);

  Future<List<UserModel>> _getUsers() async {
    final userService = UserService();
    List<String> uids = showFollowers
        ? await userService.getFollowersUIDs()
        : await userService.getFollowingUIDs();

    final List<UserModel> users = [];
    for (String uid in uids) {
      final doc = await userService.getUserProfile(uid);
      if (doc.exists) {
        final user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        users.add(user);
      }
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E8DC),
      appBar: AppBar(
        title: Text(
            showFollowers ? 'Followers' : 'Following',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
      body: FutureBuilder<List<UserModel>>(
        future: _getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ProfileTile(userId: user.uid);
            },
          );
        },
      ),
    );
  }
}*/

/*Future<List<String>> getUserUIDs() async {
    final userService = UserService();
    return showFollowers
        ? await userService.getFollowersUIDs()
        : await userService.getFollowingUIDs();
  }*/

/*FutureBuilder<List<String>>(
        future: getUserUIDs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final uids = snapshot.data ?? [];
          if (uids.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: uids.length,
            itemBuilder: (context, index) {
              return ProfileTile(userId: uids[index]);
            },
          );
        },
      ),*/