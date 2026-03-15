import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../../core/audio/audio_handler.dart';
import '../../data/models/story.dart';
import '../../data/services/youtube_service.dart';

class AudioPlayerProvider with ChangeNotifier {
  final MyAudioHandler _audioHandler;
  final YoutubeService _youtubeService = YoutubeService();
  Podcast? _currentPodcast;
  Episode? _currentEpisode;
  bool _isExtracting = false;
  
  AudioPlayer get player => _audioHandler.player;
  Podcast? get currentPodcast => _currentPodcast;
  Episode? get currentEpisode => _currentEpisode;
  bool get isPlaying => player.playing;
  bool get isExtracting => _isExtracting;
  
  // Streams for UI progress
  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Duration? get duration => player.duration;
  
  AudioPlayerProvider(this._audioHandler) {
    _init();
  }

  void _init() {
    player.playerStateStream.listen((state) {
      notifyListeners();
    });
    
    player.positionStream.listen((position) {
      notifyListeners();
    });
  }

  Future<void> playEpisode(Podcast podcast, Episode episode) async {
    if (_currentEpisode?.id == episode.id && player.playing) return;
    
    _currentPodcast = podcast;
    _currentEpisode = episode;
    
    // Only show extracting state if we are actually going to extract from YouTube
    if (episode.sourceType == "youtube" && episode.playType != "direct") {
      _isExtracting = true;
      notifyListeners();
    }
    
    try {
      String audioUrl = episode.audioUrl;

      // 1. If it's a YouTube source, extract/cache the real URL
      // Skip extraction if playType is "direct"
      if (episode.sourceType == "youtube" && episode.playType != "direct") {
        debugPrint("Extracting YouTube audio for: ${episode.title}");
        final String? extractedUrl = await _youtubeService.getAudioUrl(episode.audioUrl);
        
        if (extractedUrl != null) {
          audioUrl = extractedUrl;
        } else {
          throw Exception("Could not extract audio from YouTube URL");
        }
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

      final mediaItem = MediaItem(
        id: episode.id,
        album: podcast.title,
        title: episode.title,
        artist: podcast.author,
        artUri: Uri.parse(podcast.imageUrl),
        duration: parsedDuration,
      );
      _audioHandler.mediaItem.add(mediaItem);

      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioUrl),
          tag: mediaItem,
        ),
      );
      await player.setSpeed(1.0);
      player.play();
    } catch (e) {
      debugPrint("Error playing episode: $e");
    } finally {
      _isExtracting = false;
      notifyListeners();
    }
  }

  void togglePlay() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
    notifyListeners();
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

  @override
  void dispose() {
    _audioHandler.player.dispose();
    super.dispose();
  }
}
