import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_blog_app/pages/home_page.dart';
import 'package:my_blog_app/pages/auth/login_or_register.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
            // if user has logged in
            else if (snapshot.hasData) {
            return HomePage();
            // if user has not logged in
          }
            else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}


