import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/app_header.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final podcast = audioProvider.currentPodcast;
    final episode = audioProvider.currentEpisode;
    final screenHeight = MediaQuery.of(context).size.height;

    if (podcast == null || episode == null) {
      return const Scaffold(body: Center(child: Text("No episode selected")));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppHeader(title: "", showBack: true),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.saffron.withOpacity(0.15),
                  AppColors.background,
                  AppColors.background,
                ],
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 1. Cover Image Section - Scaled down for smaller screens
                Expanded(
                  flex: 10,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating Mandala Glow
                        Container(
                          width: screenHeight * 0.35,
                          height: screenHeight * 0.35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.saffron.withOpacity(0.2), width: 1),
                          ),
                        ).animate(onPlay: (controller) => controller.repeat())
                         .rotate(duration: 20.seconds),
                         
                        Hero(
                          tag: 'podcast_image_${podcast.id}',
                          child: Container(
                            width: screenHeight * 0.3,
                            height: screenHeight * 0.3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.deepMaroon.withOpacity(0.25),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: CachedNetworkImage(
                                imageUrl: podcast.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: AppColors.cream),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.easeOut).fadeIn(),
                      ],
                    ),
                  ),
                ),
                
                // 2. Info Section (Title & Author)
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          episode.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 22,
                            height: 1.1,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                        
                        const SizedBox(height: 8),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.deepMaroon.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                podcast.title,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.deepMaroon,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.fiber_manual_record, size: 4, color: AppColors.lightBrown),
                            const SizedBox(width: 8),
                            Text(
                              episode.duration,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms),
                      ],
                    ),
                  ),
                ),

                // 3. Audio Player Section
                Expanded(
                  flex: 11,
                  child: Column(
                    children: [
                      // Description - Compact
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          episode.description,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            height: 1.3,
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms),
                      
                      const Spacer(),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AudioPlayerWidget(audioUrl: episode.audioUrl),
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
