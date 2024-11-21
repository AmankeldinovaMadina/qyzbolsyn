import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:last/services/model/category.dart';


class CategoryService {
  final String baseUrl = "https://qyzbolsyn-backend-3.onrender.com"; // Replace with your backend URL

  // Method to fetch all categories
  // Fetch categories and return them as a Map<String, String>
  Future<Map<String, String>> fetchCategories() async {
    final response = await http.get(
      Uri.parse("$baseUrl/categories/"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      List<dynamic> categories = json.decode(response.body);

      // Convert list to Map<String, String>
      return {for (var category in categories) category['key']: category['value']};
    } else {
      throw Exception("Failed to fetch categories");
    }
  }


  // Method to add a new category
  Future<void> addCategory(String key, String value) async {
    final response = await http.post(
      Uri.parse("$baseUrl/categories/"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"key": key, "value": value}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add category");
    }
  }
}


class CategoryCache {
  static Map<String, String>? _categories;

  // Fetch categories from the backend if not already fetched
  static Future<Map<String, String>> fetchCategories() async {
    if (_categories != null) {
      return _categories!;
    }

    final response = await http.get(
      Uri.parse("https://qyzbolsyn-backend-3.onrender.com/categories/"), // Replace with your backend URL
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      List<dynamic> categories = json.decode(response.body);

      _categories = {
        for (var category in categories) category['key']: category['value']
      };

      return _categories!;
    } else {
      throw Exception("Failed to fetch categories");
    }
  }

  // Get the cached categories directly (if already fetched)
  static Map<String, String> get categories {
    if (_categories == null) {
      throw Exception("Categories have not been fetched yet!");
    }
    return _categories!;
  }
}
