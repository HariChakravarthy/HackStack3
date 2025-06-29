import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:random_string/random_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_blog_app/models/blog_model.dart';
import 'package:my_blog_app/services/blog_service.dart';



class CreateBlogScreen extends StatefulWidget {
  const CreateBlogScreen({Key? key}) : super(key: key);

  @override
  _CreateBlogScreenState createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  final List<String> categories = [ 'News', 'Politics', 'Business', 'Movies', 'Cricket', 'Technology', 'Economics', 'other'];
  String selectedCategory = 'other';

  final Map<String, IconData> _categoryIcons = {
    'News': Icons.newspaper,
    'Politics': Icons.how_to_vote,
    'Business': Icons.business_center,
    'Movies': Icons.movie,
    'Cricket': Icons.sports_cricket,
    'Technology': Icons.devices,
    'Economics': Icons.bar_chart,
    'other': Icons.more_horiz,
  };


  Future<void> uploadBlog() async {
    if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: "Title and Content cannot be empty.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data();

      if (userData == null) {
        Fluttertoast.showToast(msg: "User profile not found.");
        return;
      }

      final blogData = {
        'authorName': userData['username'] ?? 'Anonymous',
        'authorProfilePic': userData['profilePicUrl'] ?? '',
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'category': selectedCategory,
        'likes': [],
        'comments': [],
        'shares': [],
      };

      await BlogService().addBlog(blogData);

      Fluttertoast.showToast(
        msg: "Blog published!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error uploading blog: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }


  void insertMarkdown(String syntax) {
    final text = contentController.text;
    final selection = contentController.selection;
    final selectedText = selection.textInside(text);

    final newText = syntax + selectedText + syntax;
    final updated = selection.textBefore(text) + newText + selection.textAfter(text);

    contentController.text = updated;
    contentController.selection = TextSelection.collapsed(
      offset: selection.start + newText.length,
    );
  }

  Color selectedTextColor = Colors.white;
  void applyColorToSelectedText(Color color) {
    setState(() {
      selectedTextColor = color;
    });
  }

  Widget colorCircle(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(height: 4),
              Text(
                "New Blog",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[900],
                    fontSize: 25),
              ),
              const SizedBox(height: 12),
              Divider(thickness: 2, color: Colors.blue[900]),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                TextButton(
                onPressed: uploadBlog,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  minimumSize: Size(80, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Post Blog  > ',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        borderRadius: BorderRadius.circular(16),
                        dropdownColor: Colors.white,
                        style: TextStyle(fontSize: 16, color: Colors.blue[900]),
                        icon: Icon(
                            Icons.arrow_drop_down,
                          color: Colors.blue[900],
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Row(
                              children: [
                                Icon(_categoryIcons[category], size: 20, color: Colors.grey[700]),
                                const SizedBox(width: 6),
                                Text(category[0].toUpperCase() + category.substring(1)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedCategory = value!),
                      ),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Blog Title'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content', border: InputBorder.none),
                maxLines: null,
                expands: false,
              ),
              const SizedBox(height: 160),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'Bold') insertMarkdown('**');
                        if (value == 'Italic') insertMarkdown('_');
                        if (value == 'Code') insertMarkdown('`');
                        if (value == 'Heading') insertMarkdown('# ');
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(child: Text('Bold'), value: 'Bold'),
                        PopupMenuItem(child: Text('Italic'), value: 'Italic'),
                        PopupMenuItem(child: Text('Code'), value: 'Code'),
                        PopupMenuItem(child: Text('Heading'), value: 'Heading'),
                      ],
                    ),
                    PopupMenuButton<Color>(
                      icon: const Icon(Icons.color_lens, color: Colors.white),
                      onSelected: applyColorToSelectedText,
                      itemBuilder: (context) => [
                        PopupMenuItem(child: colorCircle(Colors.white), value: Colors.white),
                        PopupMenuItem(child: colorCircle(Colors.black), value: Colors.black),
                        PopupMenuItem(child: colorCircle(Colors.red.shade800), value: Colors.red.shade800),
                        PopupMenuItem(child: colorCircle(Colors.green.shade100), value: Colors.green.shade100),
                        PopupMenuItem(child: colorCircle(Colors.blue.shade800), value: Colors.blue.shade800),
                        PopupMenuItem(child: colorCircle(Colors.purple), value: Colors.purple),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.camera_alt, color: Colors.white), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.copy_rounded, color: Colors.white), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.add_box, color: Colors.white), onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
        );
  }
}
