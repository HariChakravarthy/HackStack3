/*import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_blog_app/pages/home/following_screen.dart';

class ProfileTile extends StatelessWidget {
  final String userId;

  const ProfileTile({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final username = data['username'] ?? 'Unknown';
        final profilePicUrl = data['profilePicUrl'] ?? '';
        final followers = (data['followers'] ?? []).length;
        final following = (data['following'] ?? []).length;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: profilePicUrl.isNotEmpty
                ? CachedNetworkImageProvider(profilePicUrl)
                : const AssetImage('lib/images/default_profile.jpg') as ImageProvider,
          ),
          title: Text(
              username,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
          subtitle: Text("Followers: $followers • Following: $following"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FollowingScreen(userId: userId),
              ),
            );
          },
        );
      },
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_blog_app/models/user_model.dart';
import 'package:my_blog_app/pages/home/following_screen.dart';
import 'package:my_blog_app/services/user_service.dart';

class ProfileTile extends StatelessWidget {
  final String userId;

  const ProfileTile({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: UserService().getUserProfileStream(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final user = snapshot.data!;
        final username = user.username;
        final profilePicUrl = user.profilePicUrl;
        final followersCount = user.followers.length;
        final followingCount = user.following.length;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: profilePicUrl.isNotEmpty
                ? CachedNetworkImageProvider(profilePicUrl)
                : const AssetImage('lib/images/default_profile.jpg') as ImageProvider,
          ),
          title: Text(
            username,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
          subtitle: Text("Followers: $followersCount • Following: $followingCount"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FollowingScreen(userId: userId),
              ),
            );
          },
        );
      },
    );
  }
}

