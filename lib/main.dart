import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'package:audio_service/audio_service.dart';
import 'core/audio/audio_handler.dart';
import 'presentation/providers/story_provider.dart';
import 'presentation/providers/audio_player_provider.dart';
import 'presentation/screens/splash_screen.dart';

late MyAudioHandler _audioHandler;

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize custom background audio handler
    _audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.indianstories.audiobook_app.channel.audio',
        androidNotificationChannelName: 'Shravan Audio Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  } catch (e) {
    debugPrint("CRITICAL: Audio Service init failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider(_audioHandler)),
      ],
      child: const AudiobookApp(),
    ),
  );
}

class AudiobookApp extends StatelessWidget {
  const AudiobookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shravan - Indian Audiobooks',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
