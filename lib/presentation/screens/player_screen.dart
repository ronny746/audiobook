import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/audio_player_widget.dart';
import '../../data/models/story.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool showLyrics = false;

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final podcast = audioProvider.currentPodcast;
    final episode = audioProvider.currentEpisode;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    if (podcast == null || episode == null) {
      return const Scaffold(body: Center(child: Text("No episode selected")));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient with subtle image blur
          Positioned.fill(
            child: Container(
              color: AppColors.background,
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CachedNetworkImage(
                imageUrl: podcast.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withOpacity(0.8),
                    AppColors.background.withOpacity(0.9),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                        color: AppColors.deepMaroon,
                      ),
                      Column(
                        children: [
                          Text(
                            "PLAYING FROM PODCAST",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: AppColors.deepMaroon.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            podcast.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                        color: AppColors.deepMaroon,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: showLyrics 
                      ? _buildLyricsView(episode) 
                      : _buildPlayerView(podcast, episode, screenHeight),
                  ),
                ),

                // Player Controls Section
                _buildControlsSection(episode, audioProvider),
                
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Loading Overlay
          if (audioProvider.isExtracting)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: BackdropFilter(
                filter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.saffron,
                          strokeWidth: 5,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Expanding Story...",
                          style: TextStyle(
                            color: AppColors.deepMaroon,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerView(Podcast podcast, Episode episode, double screenHeight) {
    return Column(
      key: const ValueKey("player_view"),
      children: [
        const Spacer(flex: 1),
        // Premium Cover Art
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Spinning outer ring
              Container(
                width: screenHeight * 0.38,
                height: screenHeight * 0.38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.saffron.withOpacity(0.1),
                    width: 2,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
               .rotate(duration: 30.seconds),
               
              Hero(
                tag: 'podcast_image_${podcast.id}',
                child: Container(
                  width: screenHeight * 0.32,
                  height: screenHeight * 0.32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepMaroon.withOpacity(0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: CachedNetworkImage(
                      imageUrl: podcast.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOut).fadeIn(),
            ],
          ),
        ),
        
        const Spacer(flex: 2),
        
        // Metadata
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          podcast.author,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.deepMaroon.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border, color: AppColors.deepMaroon),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                episode.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildLyricsView(Episode episode) {
    return Container(
      key: const ValueKey("lyrics_view"),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Lyrics",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.deepMaroon,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                episode.lyrics ?? "Lyrics not available for this episode.",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary.withOpacity(0.9),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsSection(Episode episode, AudioPlayerProvider audioProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          AudioPlayerWidget(audioUrl: episode.audioUrl),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined),
                color: AppColors.textSecondary,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.timer_outlined),
                color: AppColors.textSecondary,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showLyrics = !showLyrics;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: showLyrics ? AppColors.deepMaroon : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.deepMaroon.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lyrics_outlined, 
                        size: 18, 
                        color: showLyrics ? Colors.white : AppColors.deepMaroon
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Lyrics",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: showLyrics ? Colors.white : AppColors.deepMaroon,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.playlist_play),
                color: AppColors.textSecondary,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.download_for_offline_outlined),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

