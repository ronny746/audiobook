import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/story.dart';

class ApiService {
  // Replace with your actual API endpoint
  static const String baseUrl = "https://raw.githubusercontent.com/ronny746/audiobook/main/assets/data/stories.json";

  Future<List<Podcast>> fetchStories() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Podcast.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load stories from API (Status: ${response.statusCode})");
      }
    } catch (e) {
      rethrow;
    }
  }
}
