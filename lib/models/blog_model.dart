import 'package:cloud_firestore/cloud_firestore.dart';

class BlogModel {
  final String blogId;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final List<String> likes;
  final String category;
  final List<dynamic> comments;
  final List<dynamic> shares;
  final DateTime timestamp;


  BlogModel({
    required this.blogId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.category,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.timestamp,
  });

  factory BlogModel.fromMap(Map<String, dynamic> map, String docId) {
    return BlogModel(
      blogId: docId,
      authorId: map['authorId'],
      authorName: map['authorName'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      likes: List<String>.from(map['likes'] ?? []),
      comments: List<dynamic>.from(map['comments'] ?? []),
      shares: List<dynamic>.from(map['shares'] ?? []),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'blogId': blogId,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'content': content,
      'likes': likes,
      'comments': comments,
      'shares' : shares,
      'timestamp': timestamp,
      'category' : category,
    };
  }
}
