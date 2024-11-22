import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:last/services/model/talk.dart';

class TalkService {
  final String _baseUrl = 'https://qyzbolsyn-backend-3.onrender.com'; // Replace with your base URL

  // Fetch the last talk
  Future<Talk> fetchLastTalk() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/talks/talks/last'),
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Rename the variable to avoid conflict
      final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return Talk.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load the last talk');
    }
  }

  // Method to add an answer to a talk
  Future<Talk> addAnswerToTalk({
    required String talkId,
    required String username,
    required String bodyMsg,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/talks/talks/$talkId/add_answer'),
      headers: {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': username,
        'bodyMsg': bodyMsg,
        'created_at': DateTime.now().toIso8601String(), // Automatically set the creation time
      }),
    );

    if (response.statusCode == 200) {
      // Rename the variable to avoid conflict
      final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return Talk.fromJson(jsonResponse); // Return the updated talk object
    } else {
      throw Exception('Failed to add answer to the talk');
    }
  }
}
