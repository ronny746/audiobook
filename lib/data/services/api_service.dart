import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/story.dart';

class ApiService {
  // Replace with your actual API endpoint
  static const String baseUrl = "https://raw.githubusercontent.com/rohit-audiobook/api/main/stories.json";

  Future<List<Podcast>> fetchStories() async {
    try {
      // In a real app, this would be a network call
      // final response = await http.get(Uri.parse(baseUrl));
      
      // if (response.statusCode == 200) {
      //   final List<dynamic> data = json.decode(response.body);
      //   return data.map((json) => Podcast.fromJson(json)).toList();
      // } else {
      //   throw Exception("Failed to load stories from API");
      // }
      
      // MOCKING a successful API call delay for demonstration
      await Future.delayed(const Duration(seconds: 2));
      
      // For now, since we don't have a live URL, we can return empty or throw
      // to trigger the fallback in the provider, or mock local data as if it came from API
      return []; 
    } catch (e) {
      rethrow;
    }
  }
}
