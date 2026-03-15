import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/story.dart';
import '../../data/services/api_service.dart';

class StoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Podcast> _podcasts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Podcast> get podcasts => _podcasts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Try to fetch from API
      _podcasts = await _apiService.fetchStories();
      
      // 2. If API returns empty or fails (mocked for now), use local fallback
      if (_podcasts.isEmpty) {
        debugPrint("API returned empty, using local fallback...");
        final String localData = await rootBundle.loadString('assets/data/stories.json');
        final List<dynamic> jsonList = json.decode(localData);
        _podcasts = jsonList.map((json) => Podcast.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("API Error: $e. Falling back to local data...");
      try {
        final String localData = await rootBundle.loadString('assets/data/stories.json');
        final List<dynamic> jsonList = json.decode(localData);
        _podcasts = jsonList.map((json) => Podcast.fromJson(json)).toList();
      } catch (innerError) {
        _errorMessage = "Failed to load stories: $innerError";
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
