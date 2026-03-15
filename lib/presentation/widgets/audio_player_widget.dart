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
                trackHeight: 6,
                activeTrackColor: AppColors.deepMaroon,
                inactiveTrackColor: AppColors.deepMaroon.withOpacity(0.1),
                thumbColor: AppColors.deepMaroon,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8, elevation: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                trackShape: const RoundedRectSliderTrackShape(),
              ),
              child: Slider(
                value: position.inSeconds.toDouble(),
                max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
                onChanged: (value) {
                  player.seek(Duration(seconds: value.toInt()));
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
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepMaroon),
                  ),
                  Text(
                    _formatDuration(duration), 
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.deepMaroon),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Main Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.shuffle_rounded, color: AppColors.lightBrown, size: 24),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, size: 42, color: AppColors.deepMaroon),
                  onPressed: () {},
                ),
                
                // Play Button
                GestureDetector(
                  onTap: () => audioProvider.togglePlay(),
                  child: Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: AppColors.deepMaroon,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepMaroon.withOpacity(0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, size: 42, color: AppColors.deepMaroon),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.repeat_rounded, color: AppColors.lightBrown, size: 24),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        );
      }
    );
  }
}
