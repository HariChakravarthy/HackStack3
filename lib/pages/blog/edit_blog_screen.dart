import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_blog_app/models/blog_model.dart';
import 'package:my_blog_app/services/blog_service.dart';


class EditBlogScreen extends StatefulWidget {
  final BlogModel existingBlog;

  const EditBlogScreen({super.key, required this.existingBlog});

  @override
  _EditBlogScreenState createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  late String selectedCategory;

  final List<String> categories = [ 'News', 'Politics', 'Business', 'Movies', 'Cricket', 'Technology', 'Economics', 'other'];

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

  Color selectedTextColor = Colors.white;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.existingBlog.title);
    contentController = TextEditingController(text: widget.existingBlog.content);

    selectedCategory = categories.contains(widget.existingBlog.category)
        ? widget.existingBlog.category
        : categories.first;
  }


  Widget colorCircle(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
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

  void applyColorToSelectedText(Color color) {
    setState(() {
      selectedTextColor = color;
    });
  }

  Future<void> updateBlog() async {
    try {
      await BlogService().updateBlog(widget.existingBlog.blogId, {
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'category': selectedCategory,
      });

      Fluttertoast.showToast(
        msg: "Blog updated!",
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
        title: const Text("Edit Blog",
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        borderRadius: BorderRadius.circular(16),
                        dropdownColor: Colors.white,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        icon: const Icon(Icons.arrow_drop_down),
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
              ),
              const SizedBox(height:160),
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
                        PopupMenuItem(value: 'Bold', child: Text('Bold')),
                        PopupMenuItem(value: 'Italic', child: Text('Italic')),
                        PopupMenuItem(value: 'Code', child: Text('Code')),
                        PopupMenuItem(value: 'Heading', child: Text('Heading')),
                      ],
                    ),
                    PopupMenuButton<Color>(
                      icon: const Icon(Icons.color_lens, color: Colors.white),
                      onSelected: applyColorToSelectedText,
                      itemBuilder: (context) => [
                        PopupMenuItem(value: Colors.white, child: colorCircle(Colors.white)),
                        PopupMenuItem(value: Colors.black, child: colorCircle(Colors.black)),
                        PopupMenuItem(value: Colors.red.shade800, child: colorCircle(Colors.red.shade800)),
                        PopupMenuItem(value: Colors.green.shade100, child: colorCircle(Colors.green.shade100)),
                        PopupMenuItem(value: Colors.blue.shade800, child: colorCircle(Colors.blue.shade800)),
                        PopupMenuItem(value: Colors.purple, child: colorCircle(Colors.purple)),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: updateBlog,
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 2.0,
        child: const Icon(Icons.save),
      ),
    );
  }
}
