import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/auth_service.dart';
import 'package:http/http.dart' as http;
import '../../core/audio/audio_handler.dart';
import '../../data/models/story.dart';
import '../../data/services/youtube_service.dart';

class AudioPlayerProvider with ChangeNotifier {
  final MyAudioHandler _audioHandler;
  final YoutubeService _youtubeService = YoutubeService();
  Podcast? _currentPodcast;
  Episode? _currentEpisode;
  bool _isExtracting = false;
  bool _limitReached = false;
  String? _extractionError;
  final Set<String> _favoriteEpisodeIds = {};
  final List<FavoriteItem> _favoriteItems = [];
  final Set<String> _downloadedEpisodeIds = {};
  final List<HistoryItem> _listeningHistory = [];
  List<Podcast> _currentQueue = [];
  int _queueIndex = -1;
  void Function(String, {int? position, bool? isPlaying, Episode? episode, Podcast? podcast})? _onSyncCallback;
  
  void setSyncCallback(void Function(String, {int? position, bool? isPlaying, Episode? episode, Podcast? podcast}) callback) {
    _onSyncCallback = callback;
  }
  
  AudioPlayer get player => _audioHandler.player;
  Podcast? get currentPodcast => _currentPodcast;
  Episode? get currentEpisode => _currentEpisode;
  bool get isPlaying => player.playing;
  bool get isExtracting => _isExtracting;
  bool get limitReached => _limitReached; // Added limitReached getter
  String? get extractionError => _extractionError;
  
  Set<String> get favoriteEpisodeIds => _favoriteEpisodeIds;
  List<FavoriteItem> get favoriteItems => _favoriteItems;
  Set<String> get downloadedEpisodeIds => _downloadedEpisodeIds;
  List<HistoryItem> get listeningHistory => _listeningHistory;

  bool isFavorite(String id) => _favoriteEpisodeIds.contains(id);
  bool isDownloaded(String id) => _downloadedEpisodeIds.contains(id);

  Future<void> toggleFavorite(Podcast podcast, Episode? episode) async {
    final token = await AuthService.getToken();
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/user/save-item'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({'contentId': podcast.id}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bool isSaved = data['saved'];
        
        if (isSaved) {
          _favoriteEpisodeIds.add(podcast.id);
          // For local display in Saved tab
          if (!_favoriteItems.any((item) => item.podcast.id == podcast.id)) {
            _favoriteItems.add(FavoriteItem(
              podcast: podcast, 
              episode: episode ?? (podcast.episodes.isNotEmpty ? podcast.episodes.first : 
                Episode(id: podcast.id, title: podcast.title, description: podcast.description, audioUrl: podcast.youtubeId ?? "", duration: "04:00"))
            ));
          }
        } else {
          _favoriteEpisodeIds.remove(podcast.id);
          _favoriteItems.removeWhere((item) => item.podcast.id == podcast.id);
        }
        _saveToPrefs();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error toggling favorite on backend: $e");
    }
  }

  void toggleDownload(Episode episode) {
    if (_downloadedEpisodeIds.contains(episode.id)) {
      _downloadedEpisodeIds.remove(episode.id);
    } else {
      _downloadedEpisodeIds.add(episode.id);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void _addToHistory(Podcast podcast, Episode episode, {Duration position = Duration.zero}) {
    // Remove if already exists (bring to top)
    final existingIndex = _listeningHistory.indexWhere((item) => item.episode.id == episode.id);
    Duration existingPosition = position;
    Duration existingDuration = Duration.zero;
    
    if (existingIndex != -1) {
      existingPosition = _listeningHistory[existingIndex].position;
      existingDuration = _listeningHistory[existingIndex].totalDuration;
      _listeningHistory.removeAt(existingIndex);
    }

    _listeningHistory.insert(0, HistoryItem(
      podcast: podcast,
      episode: episode,
      playedAt: DateTime.now(),
      position: existingPosition,
      totalDuration: existingDuration,
    ));
    // Keep last 50 items
    if (_listeningHistory.length > 50) _listeningHistory.removeLast();
    _saveToPrefs();
    notifyListeners();
  }
  
  // Streams for UI progress
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Duration? get duration => player.duration;
  
  AudioPlayerProvider(this._audioHandler) {
    _init();
  }

  void _init() {
    _loadFromPrefs();
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNextEpisode();
      }
      notifyListeners();
    });
    
    player.positionStream.listen((position) {
      if (_currentEpisode != null && _listeningHistory.isNotEmpty) {
        if (_listeningHistory.first.episode.id == _currentEpisode!.id) {
          final first = _listeningHistory.first;
          _listeningHistory[0] = HistoryItem(
            podcast: first.podcast,
            episode: first.episode,
            playedAt: first.playedAt,
            position: position,
            totalDuration: player.duration ?? first.totalDuration,
          );
          // Save every 5 seconds to avoid excessive disk I/O
          if (position.inSeconds % 5 == 0) {
            _saveToPrefs();
          }
        }
      }
      notifyListeners();
    });
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load History
      final String? historyJson = prefs.getString('listening_history');
      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _listeningHistory.clear();
        _listeningHistory.addAll(decoded.map((item) => HistoryItem.fromJson(item)).toList());
      }
      
      // Sync Favorites from Backend
      await syncFavoriteItems();

      // Load Downloads
      final List<String>? downloads = prefs.getStringList('downloads');
      if (downloads != null) {
        _downloadedEpisodeIds.clear();
        _downloadedEpisodeIds.addAll(downloads);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading from prefs: $e");
    }
  }

  Future<void> syncFavoriteItems() async {
    final token = await AuthService.getToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/user/save-item'),
        headers: {'x-auth-token': token},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _favoriteEpisodeIds.clear();
        _favoriteItems.clear();

        for (var item in data) {
          final p = Podcast.fromJson(item);
          _favoriteEpisodeIds.add(p.id);
          _favoriteItems.add(FavoriteItem(
            podcast: p,
            episode: p.episodes.isNotEmpty ? p.episodes.first : 
                     Episode(id: p.id, title: p.title, description: p.description, audioUrl: p.youtubeId ?? "", duration: "04:00")
          ));
        }
        _saveToPrefs();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error syncing favorite items: $e");
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save History
      final historyJson = jsonEncode(_listeningHistory.map((item) => item.toJson()).toList());
      await prefs.setString('listening_history', historyJson);
      
      // Save Favorites
      final favoritesJson = jsonEncode(_favoriteItems.map((item) => item.toJson()).toList());
      await prefs.setString('favorites_items', favoritesJson);
      await prefs.setStringList('favorites', _favoriteEpisodeIds.toList());
      
      // Save Downloads
      await prefs.setStringList('downloads', _downloadedEpisodeIds.toList());
    } catch (e) {
      debugPrint("Error saving to prefs: $e");
    }
  }

  Future<void> clearAllData() async {
    _favoriteEpisodeIds.clear();
    _favoriteItems.clear();
    _downloadedEpisodeIds.clear();
    _listeningHistory.clear();
    _currentPodcast = null;
    _currentEpisode = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('listening_history');
    await prefs.remove('favorites_items');
    await prefs.remove('favorites');
    await prefs.remove('downloads');
    
    notifyListeners();
  }

  Future<void> playEpisode(Podcast podcast, Episode episode, {Duration? initialPosition, List<Podcast>? queue}) async {
    // 1. Same track check - if already playing, just return
    if (_currentEpisode?.id == episode.id && player.playing) return;
    
    // 2. Immediate feedback & State reset
    // We don't return if extracting anymore to allow user to switch quickly
    _isExtracting = true;
    
    // Stop/Pause current playback immediately so the user hears that the track changed
    try {
      if (player.playing) {
        await player.stop();
      }
    } catch (e) {
      debugPrint("Error stopping current playback: $e");
    }

    // 3. Update metadata and queue IMMEDIATELY for UI responsiveness
    _currentPodcast = podcast;
    _currentEpisode = episode;

    if (queue != null) {
      _currentQueue = queue;
      _queueIndex = _currentQueue.indexWhere((p) => p.id == podcast.id);
    } else if (_currentQueue.isEmpty || !_currentQueue.any((p) => p.id == podcast.id)) {
      _currentQueue = [podcast];
      _queueIndex = 0;
    } else {
      _queueIndex = _currentQueue.indexWhere((p) => p.id == podcast.id);
    }

    // Trigger UI update with new track info and loading spinner
    notifyListeners();

    // 4. Permission and Limit Check
    final bool canPlay = await _checkAndTrackPlay();
    if (!canPlay) {
      _isExtracting = false;
      notifyListeners();
      return;
    }
    
    _addToHistory(podcast, episode);

    // 5. Track playback in background (don't await this as it blocks playback start)
    // We already checked limits via _checkAndTrackPlay, this is just for stats
    AuthService.getToken().then((token) {
      if (token != null) {
        http.post(
          Uri.parse('${AuthService.baseUrl}/content/playback'),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
          body: jsonEncode({'contentId': podcast.id}),
        ).catchError((e) => debugPrint("Background tracking error: $e"));
      }
    });

    try {
      String audioUrl = episode.audioUrl.trim();
      debugPrint("Attempting to play track: ${episode.title}");
      _extractionError = null;

      // 6. Source extraction
      bool isYoutube = episode.sourceType == "youtube" || 
                       audioUrl.length == 11 || 
                       audioUrl.contains("youtube.com") || 
                       audioUrl.contains("youtu.be");

      if (isYoutube) {
        debugPrint("Building stream for YouTube content: $audioUrl");
        
        try {
          final String? extractedUrl = await _youtubeService.getAudioUrl(audioUrl);
          
          if (extractedUrl != null && extractedUrl.isNotEmpty) {
            audioUrl = extractedUrl;
            debugPrint("YouTube streaming URL generated successfully.");
          } else {
            _extractionError = "YouTube is rate-limiting requests. Please try again in 5 minutes.";
            notifyListeners();
            throw Exception("Could not extract YouTube stream for: $audioUrl");
          }
        } catch (e) {
          debugPrint("Extraction error: $e");
          _extractionError = "Connection error. Please check your internet or try another track.";
          notifyListeners();
          rethrow;
        }
      }

      if (audioUrl.isEmpty || audioUrl.length < 20 && !audioUrl.startsWith("http")) {
        throw Exception("Invalid audio source: $audioUrl");
      }

      Duration? parsedDuration;
      try {
        final parts = episode.duration.split(':');
        if (parts.length == 2) {
          parsedDuration = Duration(
            minutes: int.parse(parts[0]),
            seconds: int.parse(parts[1]),
          );
        }
      } catch (_) {}

      // Build artUri safely
      Uri? artUri;
      if (podcast.imageUrl.isNotEmpty) {
        try {
          artUri = Uri.parse(podcast.imageUrl);
        } catch (_) {}
      }

      final mediaItem = MediaItem(
        id: episode.id,
        album: podcast.title,
        title: episode.title,
        artist: podcast.author,
        duration: parsedDuration,
        artUri: artUri,
        extras: {'url': audioUrl},
      );
      
      // Update queue for Android Auto browsing
      if (queue != null) {
        final List<MediaItem> mediaItems = [];
        for (var p in queue) {
          if (p.episodes.isNotEmpty) {
            final e = p.episodes.first;
            mediaItems.add(MediaItem(
              id: e.id,
              album: p.title,
              title: e.title,
              artist: p.author,
              artUri: p.imageUrl.isNotEmpty ? Uri.tryParse(p.imageUrl) : null,
              extras: {'url': e.audioUrl},
            ));
          }
        }
        _audioHandler.queue.add(mediaItems);
      } else if (_currentQueue.isNotEmpty) {
        // Fallback to internal _currentQueue
        final List<MediaItem> mediaItems = [];
        for (var p in _currentQueue) {
          if (p.episodes.isNotEmpty) {
            final e = p.episodes.first;
            mediaItems.add(MediaItem(
              id: e.id,
              album: p.title,
              title: e.title,
              artist: p.author,
              artUri: p.imageUrl.isNotEmpty ? Uri.tryParse(p.imageUrl) : null,
              extras: {'url': e.audioUrl},
            ));
          }
        }
        _audioHandler.queue.add(mediaItems);
      }
      
      debugPrint("Setting MediaItem for: ${episode.title}");
      _audioHandler.mediaItem.add(mediaItem);

      final uri = Uri.parse(audioUrl);

      try {
        // Try playing with specific headers (improves compatibility)
        await player.setAudioSource(
          AudioSource.uri(
            uri,
            tag: mediaItem,
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36',
              'Referer': 'https://www.youtube.com/',
            },
          ),
          preload: false,
        );
      } catch (e) {
        debugPrint("Standard playback failed, attempting simple source fallback: $e");
        await player.setAudioSource(
          AudioSource.uri(uri, tag: mediaItem),
          preload: false,
        );
      }

      await player.setSpeed(1.0);
      
      if (initialPosition != null) {
        await player.seek(initialPosition);
      }
      
      player.play();
      _onSyncCallback?.call('play_pause', isPlaying: true, position: 0, episode: episode, podcast: podcast);
    } catch (e) {
      debugPrint("Final Playback Error: $e");
      _isExtracting = false;
      notifyListeners();
    } finally {
      _isExtracting = false;
      notifyListeners();
    }
  }

  void togglePlay() {
    if (player.playing) {
      player.pause();
      _onSyncCallback?.call('play_pause', isPlaying: false, episode: _currentEpisode, podcast: _currentPodcast);
    } else {
      player.play();
      _onSyncCallback?.call('play_pause', isPlaying: true, episode: _currentEpisode, podcast: _currentPodcast);
    }
    notifyListeners();
  }

  void skipForward() {
    final newPos = player.position + const Duration(seconds: 10);
    player.seek(newPos);
    _onSyncCallback?.call('seek', position: newPos.inMilliseconds, episode: _currentEpisode, podcast: _currentPodcast);
  }

  void skipBackward() {
    final newPos = player.position - const Duration(seconds: 10);
    player.seek(newPos);
    _onSyncCallback?.call('seek', position: newPos.inMilliseconds, episode: _currentEpisode, podcast: _currentPodcast);
  }

  void playNextEpisode() async {
    if (_currentPodcast == null || _currentEpisode == null) return;
    
    final episodes = _currentPodcast!.episodes;
    final episodeIndex = episodes.indexWhere((e) => e.id == _currentEpisode!.id);
    
    if (episodeIndex != -1 && episodeIndex < episodes.length - 1) {
      // Play next episode in current podcast
      playEpisode(_currentPodcast!, episodes[episodeIndex + 1]);
    } else {
      // Logic for single song repeat or following queue
      if (_currentPodcast!.contentType == 'music' || _currentPodcast!.contentType == 'movie') {
        // Repeat the same music if it's a single track
        await player.seek(Duration.zero);
        player.play();
      } else if (_queueIndex != -1 && _queueIndex < _currentQueue.length - 1) {
        // Play first episode of next podcast in queue
        final nextPodcast = _currentQueue[_queueIndex + 1];
        if (nextPodcast.episodes.isNotEmpty) {
          playEpisode(nextPodcast, nextPodcast.episodes.first);
        }
      }
    }
  }

  void playPreviousEpisode() {
    if (_currentPodcast == null || _currentEpisode == null) return;
    final index = _currentPodcast!.episodes.indexWhere((e) => e.id == _currentEpisode!.id);
    if (index > 0) {
      playEpisode(_currentPodcast!, _currentPodcast!.episodes[index - 1]);
    }
  }

  void stop() {
    player.stop();
    _currentPodcast = null;
    _currentEpisode = null;
    notifyListeners();
  }

  // Legacy method to avoid compilation errors
  Future<void> playStory(Podcast podcast) async {
    if (podcast.episodes.isNotEmpty) {
      await playEpisode(podcast, podcast.episodes.first);
    }
  }

  Future<bool> _checkAndTrackPlay() async {
    final token = await AuthService.getToken();
    if (token == null) return true;

    try {
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}/user/track-play'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 403) {
        debugPrint("Free limit reached!");
        _limitReached = true;
        notifyListeners();
        return false;
      }
      
      _limitReached = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error tracking play: $e");
      return true;
    }
  }

  void resetLimit() {
    _limitReached = false;
    notifyListeners();
  }

  void clearExtractionError() {
    _extractionError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioHandler.player.dispose();
    super.dispose();
  }
}
