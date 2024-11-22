import 'dart:convert';
import 'package:http/http.dart' as http;

class Talk {
  final String id;
  final String question;
  final List<dynamic> answers;
  final String createdAt;

  Talk({
    required this.id,
    required this.question,
    required this.answers,
    required this.createdAt,
  });

  // Factory method to parse JSON
  factory Talk.fromJson(Map<String, dynamic> json) {
    return Talk(
      id: json['_id'],
      question: json['question'],
      answers: json['answers'] ?? [],
      createdAt: json['created_at'],
    );
  }
}