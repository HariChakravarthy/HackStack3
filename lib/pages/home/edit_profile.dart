import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_blog_app/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_blog_app/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';


class EditProfileScreen extends StatefulWidget {
  final UserModel existingUser;

  const EditProfileScreen({super.key, required this.existingUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  late TextEditingController usernameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState() ;
    usernameController = TextEditingController(text: widget.existingUser.username);
    emailController = TextEditingController(text: widget.existingUser.email);
  }

  Future<void> updateUserProfile() async {
    try {
      await UserService().updateUserProfile(widget.existingUser.uid, {
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
      });

      Fluttertoast.showToast(
        msg: "Profile updated!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 14.0,
      );

      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating blog: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E8DC),
      appBar: AppBar(
        title: const Text("Edit Profile",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: widget.existingUser.profilePicUrl.isNotEmpty
                    ? CachedNetworkImageProvider(widget.existingUser.profilePicUrl)
                    : const AssetImage('lib/images/default_profile.jpg') as ImageProvider,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                child: Text(
                  "Change Profile Picture",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                    labelText: 'username',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true ,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'email',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  fillColor: Colors.grey.shade200,
                  filled: true ,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height:160),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: updateUserProfile,
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 2.0,
        child: const Icon(Icons.save),
      ),
    );
  }
}

