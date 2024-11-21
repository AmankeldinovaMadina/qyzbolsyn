import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:last/services/model/post.dart';

class ApiService {
  // Method to fetch posts from a specific category
  Future<List<Post>> fetchPosts({String? category}) async {
    final response = await http.get(
      Uri.parse('https://qyzbolsyn-backend-3.onrender.com/posts/posts/'),
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Decode the response body
      List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      List<Post> allPosts = jsonResponse.map((data) => Post.fromJson(data)).toList();

      // If a category is specified, filter the posts
      if (category != null) {
        allPosts = allPosts.where((post) => post.category == category).toList();
      }

      return allPosts;
    } else {
      throw Exception('Failed to load posts');
    }
  }
}
