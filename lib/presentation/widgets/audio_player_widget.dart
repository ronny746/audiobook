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
                thumbColor: AppColors.saffron,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(_formatDuration(duration), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Main Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: AppColors.lightBrown, size: 22),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.replay_10_rounded, size: 32, color: AppColors.deepMaroon),
                  onPressed: () => player.seek(Duration(seconds: position.inSeconds - 10)),
                ),
                
                // Play Button
                GestureDetector(
                  onTap: () => audioProvider.togglePlay(),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.deepMaroon,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepMaroon.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                IconButton(
                  icon: const Icon(Icons.forward_30_rounded, size: 32, color: AppColors.deepMaroon),
                  onPressed: () => player.seek(Duration(seconds: position.inSeconds + 30)),
                ),
                IconButton(
                  icon: const Icon(Icons.repeat_one_rounded, color: AppColors.lightBrown, size: 22),
                  onPressed: () {},
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Utilities
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.lightBrown.withOpacity(0.2)),
                  ),
                  child: IntrinsicWidth(
                    child: Row(
                      children: [
                        const Icon(Icons.speed_rounded, size: 14, color: AppColors.deepMaroon),
                        const SizedBox(width: 4),
                        StreamBuilder<double>(
                          stream: player.speedStream,
                          builder: (context, snapshot) {
                            final speed = snapshot.data ?? 1.0;
                            return DropdownButton<double>(
                              value: speed,
                              iconSize: 16,
                              underline: const SizedBox(),
                              isDense: true,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.deepMaroon),
                              items: [0.5, 0.8, 1.0, 1.2, 1.5, 2.0].map((e) {
                                return DropdownMenuItem(value: e, child: Text("${e}x"));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) player.setSpeed(val);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 15,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.share_outlined, size: 16, color: AppColors.deepMaroon),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        );
      }
    );
  }
}
