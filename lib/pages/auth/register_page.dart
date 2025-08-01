import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_blog_app/components/my_text_field.dart';
import 'package:my_blog_app/components/my_button.dart';
import 'package:my_blog_app/components/square_title.dart';
import 'package:my_blog_app/pages/home_page.dart';
import 'package:my_blog_app/services/auth_service.dart';
import 'package:my_blog_app/services/user_service.dart';



class RegisterPage extends StatefulWidget{
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
 // const is removed
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirm_passwordController = TextEditingController();
  final usernameController = TextEditingController();



  // to sign in the user
  void signUserUp() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
    );

    if ( passwordController.text != confirm_passwordController.text ) {
      Navigator.pop(context);
      showErrorMessage("Passwords don't match ");
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Create user profile in firestore
      // successfully used the function in the User Service.dart
      await UserService().createUserProfile({
        'uid': userCredential.user!.uid,
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'profilePicUrl': 'https://picsum.photos/200?random=${DateTime.now().millisecondsSinceEpoch}',   // gives random image
        'followers': [],
        'following': [],
        'blogs': [],
      });

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.message ?? "Registration failed");
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage("Something went wrong. Try again.");
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue[900],
          title: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // everything in the page is under scaffold in general
      // it is a foundational structure or pre-built framework
      backgroundColor: Color(0xFFE8E8DC),
      body: SafeArea(
        // the place where the interactive UI elements are placed
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20), // used for vertical displacement
                // logo
                Image.asset(
                  'lib/images/logo_name.jpg',
                  width: 300,
                  height: 80,
                ),
                // any scroll/line that you want place on the UI use this Text function
                const SizedBox(height: 10),
                Text(
                  'Welcome to our way2blogs ',
                  style: TextStyle(  // to style the text remember this syntax and
                    // TextStyle function which had different methods
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                // whenever there is repetitive use of UI use another dart function and call here
                // username TextField
                const SizedBox(height: 30),
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                // MyTextField is a Function with 3 parameters
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ) ,
                // password TextField
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ) ,
                // forgot password?
                const SizedBox(height: 10),
                MyTextField(
                  controller: confirm_passwordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ) ,
                // the Padding widget is used for a straightforward but
                // crucial purpose: to create empty space  around another widget.
                const SizedBox(height: 25),
                HariButton(
                  text: 'Sign Up',
                  onTap: signUserUp,
                ),
                const SizedBox(height: 30),
                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[500]
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // to get it at the center
                  // google + facebook sign in buttons
                  children: [
                    HariSquaretitle(
                      onTap: () => AuthService().signInWithGoogle(),
                      imagePath: 'lib/images/google.png',
                    ),
                    const SizedBox(width: 20),
                    /*HariSquaretitle(
                      imagePath: 'lib/images/microsoft.png',
                      onTap: () {
                      },
                    ),*/
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // child: Used when a widget accepts only one widget inside it.
                  // children: Used when a widget accepts multiple widgets inside it.
                  children: [
                    Text(
                      'Already have an account ? ',
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 16.0,             // Set size
                          fontWeight: FontWeight.bold,
                        ),
                      ), // not a member? register now
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
