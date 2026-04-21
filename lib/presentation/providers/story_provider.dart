import 'package:flutter/material.dart';
import '../../data/models/story.dart';
import '../../core/services/content_service.dart';

class StoryProvider with ChangeNotifier {
  Map<String, List<Podcast>> _homeSections = {};
  List<Podcast> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, List<Podcast>> get homeSections => _homeSections;
  List<Podcast> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _homeSections = await ContentService.getHomeContent();
      if (_homeSections.isEmpty) {
        _errorMessage = "No content found.";
      }
    } catch (e) {
      debugPrint("API Error: $e");
      _errorMessage = "Failed to load content.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await ContentService.searchContent(query);
    } catch (e) {
      debugPrint("Search Error: $e.");
      _searchResults = [];
      _errorMessage = "Failed to search content.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> trackPlayback(String contentId) async {
    try {
      await ContentService.trackPlayback(contentId);
    } catch (e) {
      debugPrint("Error tracking playback: $e");
    }
  }
}
