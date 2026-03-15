import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();
  static const String _cacheKeyPrefix = "yt_cache_";

  Future<String?> getAudioUrl(String videoUrlOrId) async {
    String? videoId;
    try {
      videoId = VideoId.parseVideoId(videoUrlOrId);
    } catch (e) {
      // If parsing fails, try to use it as a direct ID if it's 11 chars
      if (videoUrlOrId.length == 11) {
        videoId = videoUrlOrId;
      } else {
        return null;
      }
    }
    
    if (videoId == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = "$_cacheKeyPrefix$videoId";
    
    // 1. Check local cache
    final String? cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      final Map<String, dynamic> data = json.decode(cachedData);
      final String url = data['url'];
      final int expiry = data['expiry'];
      
      // Check if not expired (with 10-min buffer)
      if (DateTime.now().millisecondsSinceEpoch < (expiry - 600000)) {
        // Only use cache if it was already an m4a or if we don't care.
        // But the error -11828 is usually webm on iOS.
        return url;
      }
    }

    // 2. Fetch new URL if not cached or expired
    try {
      // In 3.0.5, we can use yt.videos.streams.getManifest
      final StreamManifest manifest = await _yt.videos.streams.getManifest(videoId);
      
      // Prefer M4A for higher compatibility with iOS/macOS players
      AudioOnlyStreamInfo? streamInfo;
      try {
        final m4aStreams = manifest.audioOnly.where((s) => 
          s.container.name.toLowerCase().contains('m4a') || 
          s.audioCodec.toLowerCase().contains('mp4')
        );
        
        
        if (m4aStreams.isNotEmpty) {
          streamInfo = m4aStreams.withHighestBitrate();
        } else {
          streamInfo = manifest.audioOnly.withHighestBitrate();
        }
      } catch (e) {
        streamInfo = manifest.audioOnly.withHighestBitrate();
      }

      final String streamUrl = streamInfo.url.toString();
      
      // Cache for 5 hours (Youtube URLs usually last 6h)
      final int expiry = DateTime.now().add(const Duration(hours: 5)).millisecondsSinceEpoch;
      await prefs.setString(cacheKey, json.encode({
        'url': streamUrl,
        'expiry': expiry,
      }));
      
      return streamUrl;
    } catch (e) {
      debugPrint("Error extracting YouTube audio: $e");
      return null;
    }
  }

  void dispose() {
    _yt.close();
  }
}
