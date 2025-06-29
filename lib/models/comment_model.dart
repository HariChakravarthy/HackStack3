import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String commentId;
  final String commenterId;
  final String commenterName;
  final String content;
  final DateTime timestamp;

  CommentModel({
    required this.commentId,
    required this.commenterId,
    required this.commenterName,
    required this.content,
    required this.timestamp,
  });

  // Convert Firestore document to CommentModel
  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      commentId: id,
      commenterId: map['commenterId'] ?? '',
      commenterName: map['commenterName'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),

    );
  }

  // Convert CommentModel to Map for uploading
  Map<String, dynamic> toMap() {
    return {
      'commenterId': commenterId,
      'commenterName': commenterName,
      'content': content,
      'timestamp': timestamp,
    };
  }
}
