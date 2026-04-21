import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';
import '../../core/theme/app_theme.dart';
import '../providers/audio_player_provider.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final podcast = audioProvider.currentPodcast;
    final episode = audioProvider.currentEpisode;

    if (podcast == null || episode == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => const PlayerScreen()),
        );
      },
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepMaroon.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    // Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CachedNetworkImage(
                          imageUrl: podcast.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[100]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title & Author
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 18,
                            child: Marquee(
                              text: episode.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              blankSpace: 20.0,
                              velocity: 30.0,
                              pauseAfterRound: const Duration(seconds: 1),
                              startPadding: 10.0,
                            ),
                          ),
                          SizedBox(
                            height: 14,
                            child: Marquee(
                              text: podcast.title,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              blankSpace: 20.0,
                              velocity: 25.0,
                              pauseAfterRound: const Duration(seconds: 2),
                              startPadding: 10.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Controls
                    if (audioProvider.isExtracting)
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.saffron),
                        ),
                      )
                    else
                      IconButton(
                        icon: Icon(
                          audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: AppColors.deepMaroon,
                        ),
                        onPressed: () => audioProvider.togglePlay(),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                      onPressed: () => audioProvider.stop(),
                    ),
                  ],
                ),
              ),
            ),
            // Mini Slider (Progress Indicator)
            StreamBuilder<Duration>(
              stream: audioProvider.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final total = audioProvider.duration ?? Duration.zero;
                double progress = 0.0;
                if (total.inMilliseconds > 0) {
                  progress = position.inMilliseconds / total.inMilliseconds;
                }
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.saffron.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saffron),
                    minHeight: 3,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
