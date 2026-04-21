import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer(
    userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36',
  );

  MyAudioHandler() {
    _init();
  }

  void _init() {
    // Broadcast player state changes
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    
    // Listen to media item changes to update system media center
    mediaItem.where((item) => item != null).listen((item) {
      if (item != null) {
        // You could update queue and other things here if needed
      }
    });
  }

  @override
  Future<dynamic> onGetRoot(Map<String, dynamic>? options) async {
    return null; // For simple implementations, returning null or Map works
  }

  @override
  Future<List<MediaItem>> loadChildren(String parentMediaId) async {
    switch (parentMediaId) {
      case 'root':
        return [
          const MediaItem(
            id: 'trending',
            title: 'Trending Music',
            playable: false,
          ),
          const MediaItem(
            id: 'favorites',
            title: 'Favorites',
            playable: false,
          ),
        ];
      case 'trending':
        // Return latest played items as a simple implementation for now
        // This will allow Android Auto to show "something" to play
        return queue.value;
      case 'favorites':
        return queue.value;
      default:
        return [];
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> fastForward() async {
    final newPosition = _player.position + const Duration(seconds: 10);
    await _player.seek(newPosition);
  }

  @override
  Future<void> rewind() async {
    final newPosition = _player.position - const Duration(seconds: 10);
    await _player.seek(newPosition);
  }

  /// Transform just_audio events to audio_service PlaybackState
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
        MediaControl.skipToNext,
        MediaControl.skipToPrevious,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  // Exposed for the provider to set sources
  AudioPlayer get player => _player;
}
