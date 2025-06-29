import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_blog_app/services/user_service.dart';

class FollowButton extends StatefulWidget {
  final String authorId;

  const FollowButton({Key? key, required this.authorId}) : super(key: key);

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isFollowing = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkFollowingStatus();
  }

  Future<void> checkFollowingStatus() async {
    final followingUIDs = await UserService().getFollowingUIDs();
    setState(() {
      isFollowing = followingUIDs.contains(widget.authorId);
      isLoading = false;
    });
  }

  Future<void> toggleFollow() async {
    setState(() {
      isFollowing = !isFollowing;
    });

    if (isFollowing) {
      await UserService().followUser(widget.authorId);
    } else {
      await UserService().unfollowUser(widget.authorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don’t show follow button on your own profile
    if (isLoading || currentUserId == widget.authorId) return const SizedBox();

    return TextButton(
      onPressed: toggleFollow,
      style: TextButton.styleFrom(
        backgroundColor: isFollowing ? Colors.blueGrey : Colors.blue[900],
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        minimumSize: Size(80, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        isFollowing ? 'Unfollow' : 'Follow',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
