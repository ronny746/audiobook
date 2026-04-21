import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../core/services/auth_service.dart';
import '../providers/audio_player_provider.dart';
import '../../data/models/story.dart';

class RoomSyncProvider with ChangeNotifier {
  IO.Socket? _socket;
  String? _roomId;
  bool _isConnected = false;
  final AudioPlayerProvider _audioProvider;

  RoomSyncProvider(this._audioProvider) {
    _audioProvider.setSyncCallback(broadcastUpdate);
    _loadStateAndConnect();
  }

  void broadcastUpdate(String type, {int? position, bool? isPlaying, Episode? episode, Podcast? podcast}) {
    if (_socket == null || !_isConnected || _roomId == null) return;

    final data = {
      'roomId': _roomId,
      'type': type,
      'position': position ?? _audioProvider.player.position.inMilliseconds,
      'isPlaying': isPlaying ?? _audioProvider.player.playing,
      'episode': episode?.toJson(),
      'podcast': podcast?.toJson(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _socket!.emit('playback_update', data);
  }

  Future<void> _loadStateAndConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRoomId = prefs.getString('pinned_room_id');
    final userId = prefs.getString('auth_user_id') ?? "anonymous";
    
    if (savedRoomId != null && savedRoomId.isNotEmpty) {
      debugPrint("Auto-reconnecting to room: $savedRoomId");
      joinRoom(savedRoomId, userId);
    }
  }

  String? get roomId => _roomId;
  bool get isConnected => _isConnected;

  void joinRoom(String roomId, String userId) {
    if (_socket != null) _socket!.disconnect();

    _socket = IO.io(AuthService.baseUrl.replaceAll('/api', ''), <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      debugPrint('Connected to Sync Server');
      _isConnected = true;
      _roomId = roomId;
      _socket!.emit('join_room', {'roomId': roomId, 'user': userId});
      
      // Persist the room ID
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('pinned_room_id', roomId);
      });
      
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      debugPrint('Disconnected from Sync Server');
      _isConnected = false;
      notifyListeners();
    });

    // Handle Incoming Sync Commands from Other Users
    _socket!.on('playback_command', (data) {
      debugPrint('Sync command received: ${data['type']}');
      _handleRemoteCommand(data);
    });

    _socket!.on('sync_state', (data) {
      debugPrint('State sync received: $data');
      _handleInitialSync(data);
    });
  }

  void _handleInitialSync(Map<String, dynamic> data) async {
    final bool isPlaying = data['isPlaying'] ?? false;
    final int lastPos = data['lastPosition'] ?? 0;
    
    // Check if there is a current track in the room
    if (data['currentTrack'] != null && data['currentTrack']['episode'] != null) {
      try {
        final episode = Episode.fromJson(data['currentTrack']['episode']);
        final podcast = Podcast.fromJson(data['currentTrack']['podcast']);
        
        // If we are not playing this track, start it
        if (_audioProvider.currentEpisode?.id != episode.id) {
          debugPrint("Sync: Playing existing room track ${episode.title}");
          await _audioProvider.playEpisode(podcast, episode);
        }
        
        // After starting (or if already on track), sync state
        _audioProvider.player.seek(Duration(milliseconds: lastPos));
        if (isPlaying) {
          _audioProvider.player.play();
        } else {
          _audioProvider.player.pause();
        }
      } catch (e) {
        debugPrint("Initial sync error: $e");
      }
    }
  }

  void _handleRemoteCommand(Map<String, dynamic> data) async {
    final String type = data['type'];
    final int? position = data['position'];
    final bool? isPlaying = data['isPlaying'];
    final Map<String, dynamic>? episodeJson = data['episode'];
    final Map<String, dynamic>? podcastJson = data['podcast'];

    // 1. Sync Track if broadcast includes it
    if (episodeJson != null && podcastJson != null) {
      try {
        final episode = Episode.fromJson(episodeJson);
        final podcast = Podcast.fromJson(podcastJson);
        
        if (_audioProvider.currentEpisode?.id != episode.id) {
          debugPrint("Sync: Remote track change to ${episode.title}");
          await _audioProvider.playEpisode(podcast, episode);
        }
      } catch (e) {
        debugPrint("Remote track change error: $e");
      }
    }

    // 2. Playback Control
    if (type == 'play_pause' && isPlaying != null) {
      if (isPlaying) {
        if (position != null) {
          _audioProvider.player.seek(Duration(milliseconds: position));
        }
        _audioProvider.player.play();
      } else {
        _audioProvider.player.pause();
      }
    } else if (type == 'seek' && position != null) {
      _audioProvider.player.seek(Duration(milliseconds: position));
    }
  }

  void leaveRoom() async {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
    _roomId = null;
    _isConnected = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pinned_room_id');
    
    notifyListeners();
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}
