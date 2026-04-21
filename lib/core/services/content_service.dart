import 'dart:convert';
import 'package:audiobook_app/data/models/story.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';


class ContentService {
  static const String baseUrl = AuthService.baseUrl;

  static Future<Map<String, List<Podcast>>> getHomeContent() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/content/home'),
      headers: {'x-auth-token': token ?? ''},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> sectionsRaw = data['sections'];
      
      Map<String, List<Podcast>> sections = {};
      for (var section in sectionsRaw) {
        String title = section['title'];
        List<dynamic> items = section['items'];
        sections[title] = items.map((item) => Podcast.fromJson(item)).toList();
      }
      return sections;
    }
    return {};
  }

  static Future<List<Podcast>> searchContent(String query) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/content/search?q=$query'),
      headers: {'x-auth-token': token ?? ''},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Podcast.fromJson(item)).toList();
    }
    return [];
  }

  static Future<Podcast?> getContentDetail(String id) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/content/detail/$id'),
      headers: {'x-auth-token': token ?? ''},
    );

    if (response.statusCode == 200) {
      return Podcast.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<void> trackPlayback(String contentId) async {
    final token = await AuthService.getToken();
    await http.post(
      Uri.parse('$baseUrl/content/playback'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token ?? '',
      },
      body: jsonEncode({'contentId': contentId}),
    );
  }

  static Future<bool> toggleSaveItem(String contentId) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/user/save-item'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': token ?? '',
      },
      body: jsonEncode({'contentId': contentId}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['saved'] ?? false;
    }
    return false;
  }
}
