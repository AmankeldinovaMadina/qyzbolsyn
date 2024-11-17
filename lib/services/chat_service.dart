import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatService {
  final String apiKey;

  ChatService() : apiKey = dotenv.env['OPEN_AI'] ?? '' {
    if (apiKey.isEmpty) {
      throw Exception("API key is missing or not loaded properly.");
    }
  }

  Future<String> sendMessage(List<Map<String, String>> messages) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    print("Sending request with API key: $apiKey");  // Debugging API key
    print("Messages being sent: $messages");         // Debugging message history

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',         // Model
        'messages': messages,     // Full conversation history
        'temperature': 0.7,       // Optional: Adjust creativity of responses
        // 'max_tokens': 200,        // Optional: Control response length
      }),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");  // Log full response

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));  // UTF-8 decoding
      final choices = data['choices'];
      if (choices != null && choices.isNotEmpty) {
        final message = choices[0]['message'];
        final content = message != null ? message['content'] : null;
        if (content != null) {
          return content;
        }
      }
      throw Exception('Invalid API response format: Missing content');
    } else {
      throw Exception('Failed to load response');
    }
  }
}
