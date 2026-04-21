import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/story.dart';

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();
  final Map<String, String> _memoryCache = {};

  Future<String?> getAudioUrl(String videoUrlOrId) async {
    try {
      final String id = VideoId(videoUrlOrId).value;

      /// ⚡ If already cached → instant return
      if (_memoryCache.containsKey(id)) {
        return _memoryCache[id]!;
      }

      /// Fetch fresh using streamsClient for better reliability
      final manifest = await _yt.videos.streamsClient.getManifest(id);
      final url = manifest.muxed.bestQuality.url.toString();

      /// Save to memory cache
      _memoryCache[id] = url;

      debugPrint("Successfully extracted YouTube URL for: $url");
      return url;
    } catch (e) {
      debugPrint("YouTube extraction error: $e");
      return null;
    }
  }

  Future<List<Podcast>> searchTracks(String query) async {
    try {
      debugPrint("YouTube Search for: $query");
      final searchList = await _yt.search.search(query);

      return searchList.take(4).map((video) {
        final episode = Episode(
          id: video.id.value,
          title: video.title,
          description: video.description,
          audioUrl: video.id.value,
          duration: video.duration
                  ?.toString()
                  .split('.')
                  .first
                  .padLeft(8, "0")
                  .substring(3) ??
              "04:00",
          sourceType: "youtube",
          playType: "youtube",
        );

        return Podcast(
          id: video.id.value,
          title: video.title,
          description: video.description,
          imageUrl: video.thumbnails.maxResUrl.isNotEmpty
              ? video.thumbnails.maxResUrl
              : video.thumbnails.highResUrl,
          author: video.author,
          category: "YouTube Music",
          playType: "music",
          episodes: [episode],
        );
      }).toList();
    } catch (e) {
      debugPrint("YouTube search tracks error: $e");
      return [];
    }
  }

  Future<String?> searchVideoId(String query) async {
    try {
      debugPrint("Searching YouTube for: $query");
      final searchList = await _yt.search.search(query);
      if (searchList.isNotEmpty) {
        return searchList.first.id.value;
      }
    } catch (e) {
      debugPrint("YouTube search error: $e");
    }
    return null;
  }

  void dispose() {
    _yt.close();
  }
}
