import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'package:audio_service/audio_service.dart';
import 'core/audio/audio_handler.dart';
import 'presentation/providers/story_provider.dart';
import 'presentation/providers/audio_player_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/room_sync_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';


import 'package:flutter/services.dart';
import 'package:audio_session/audio_session.dart';

late MyAudioHandler _audioHandler;

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Initialize Audio Session for better platform compatibility
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    
    // Configure Premium Status Bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Immersive look
      statusBarIconBrightness: Brightness.dark, // Dark icons for light theme
      statusBarBrightness: Brightness.light, // For iOS
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    
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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => AudioPlayerProvider(_audioHandler)),
        ChangeNotifierProxyProvider<AudioPlayerProvider, RoomSyncProvider>(
          create: (context) => RoomSyncProvider(context.read<AudioPlayerProvider>()),
          update: (context, audio, sync) => sync ?? RoomSyncProvider(audio),
        ),
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
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isInitialized) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.saffron),
              ),
            );
          }
          if (!auth.isAuthenticated) {
            return const LoginScreen();
          }
          return const SplashScreen();
        },
      ),
    );
  }
}
