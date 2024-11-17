import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:last/services/model/post.dart';

class ApiService {
  Future<List<Post>> fetchPosts() async {
    final response = await http.get(
      Uri.parse('https://qyzbolsyn-backend-3.onrender.com/posts/'),
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Use utf8.decode to ensure the body is properly decoded as UTF-8
      List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((data) => Post.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
