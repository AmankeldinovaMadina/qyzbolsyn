import 'dart:convert';

class Category {
  final String key;
  final String value;

  Category({required this.key, required this.value});

  // Factory constructor to parse JSON data
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      key: json['key'],
      value: json['value'],
    );
  }
}
