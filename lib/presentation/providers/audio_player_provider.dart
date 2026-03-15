import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../../core/audio/audio_handler.dart';
import '../../data/models/story.dart';

class AudioPlayerProvider with ChangeNotifier {
  final MyAudioHandler _audioHandler;
  Podcast? _currentPodcast;
  Episode? _currentEpisode;
  
  AudioPlayer get player => _audioHandler.player;
  Podcast? get currentPodcast => _currentPodcast;
  Episode? get currentEpisode => _currentEpisode;
  bool get isPlaying => player.playing;
  
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
    if (_currentEpisode?.id == episode.id) return;
    
    _currentPodcast = podcast;
    _currentEpisode = episode;
    notifyListeners();
    
    try {
      final mediaItem = MediaItem(
        id: episode.id,
        album: podcast.title,
        title: episode.title,
        artist: podcast.author,
        artUri: Uri.parse(podcast.imageUrl),
        duration: Duration(minutes: int.tryParse(episode.duration.split(':').first) ?? 0),
      );
      _audioHandler.mediaItem.add(mediaItem);

      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(episode.audioUrl),
          tag: mediaItem,
        ),
      );
      await player.setSpeed(1.0);
      player.play();
    } catch (e) {
      debugPrint("Error playing episode: $e");
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
