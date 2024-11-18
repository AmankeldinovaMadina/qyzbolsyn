import 'dart:convert';
import 'package:http/http.dart' as http;

// Define a model class for the Podcast
class Podcast {
  final String id;
  final String title;
  final String url;
  final String author;
  final String category;
  final String description;
  final List<Timecode> timecode;
  final String videoLength;

  Podcast({
    required this.id,
    required this.title,
    required this.url,
    required this.author,
    required this.category,
    required this.description,
    required this.timecode,
    required this.videoLength,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    var timecodeList = (json['timecode'] as List)
        .map((item) => Timecode.fromJson(item))
        .toList();

    return Podcast(
      id: json['_id'],
      title: json['title'],
      url: json['url'],
      author: json['author'],
      category: json['category'],
      description: json['description'],
      timecode: timecodeList,
      videoLength: json['video_length'],
    );
  }
}

class Timecode {
  final String time;
  final String label;

  Timecode({required this.time, required this.label});

  factory Timecode.fromJson(Map<String, dynamic> json) {
    return Timecode(
      time: json['time'],
      label: json['label'],
    );
  }
}
