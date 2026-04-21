import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../../core/theme/app_theme.dart';

class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({super.key, required String audioUrl});

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final player = audioProvider.player;

    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = player.duration ?? Duration.zero;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Slider Section
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: AppColors.deepMaroon,
                inactiveTrackColor: AppColors.deepMaroon.withOpacity(0.1),
                thumbColor: AppColors.deepMaroon,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                trackShape: const RoundedRectSliderTrackShape(),
              ),
              child: Slider(
                value: (position.inSeconds.toDouble() <= (duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0)) 
                       ? position.inSeconds.toDouble() 
                       : 0.0,
                max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
                onChanged: (value) {
                  if (duration.inSeconds > 0) {
                    player.seek(Duration(seconds: value.toInt()));
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    _formatDuration(position), 
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.deepMaroon.withOpacity(0.6)),
                  ),
                  Text(
                    _formatDuration(duration), 
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.deepMaroon.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Main Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, size: 48, color: AppColors.deepMaroon),
                  onPressed: () => audioProvider.playPreviousEpisode(),
                ),
                const SizedBox(width: 20),
                // Play Button
                GestureDetector(
                  onTap: () => audioProvider.togglePlay(),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: AppColors.deepMaroon,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 48, color: AppColors.deepMaroon),
                  onPressed: () => audioProvider.playNextEpisode(),
                ),
              ],
            ),
          ],
        );
      }
    );
  }
}
