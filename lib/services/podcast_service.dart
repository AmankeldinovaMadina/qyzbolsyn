import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:last/services/model/podcast.dart';

class PodcastService {
  // Method to fetch podcasts from a specific category
  Future<List<Podcast>> fetchPodcasts({String? category}) async {
    final response = await http.get(
      Uri.parse('https://qyzbolsyn-backend-3.onrender.com/podcasts/podcasts/'),
      headers: {'accept': 'application/json', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Decode the response body using utf8
      List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      List<Podcast> allPodcasts = jsonResponse.map((data) => Podcast.fromJson(data)).toList();

      // If a category is specified, filter the podcasts
      if (category != null) {
        allPodcasts = allPodcasts.where((podcast) => podcast.category == category).toList();
      }

      return allPodcasts;
    } else {
      throw Exception('Failed to load podcasts');
    }
  }

  // Method to fetch a single podcast by ID
  Future<Podcast> fetchPodcastById(String podcastId) async {
    final response = await http.get(
      Uri.parse('https://qyzbolsyn-backend-3.onrender.com/podcasts/podcasts/$podcastId'),
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Decode the response using utf8 to handle special characters
      Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return Podcast.fromJson(jsonResponse); // Create Podcast object
    } else {
      throw Exception('Failed to load podcast');
    }
  }
}
