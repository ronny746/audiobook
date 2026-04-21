import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../providers/audio_player_provider.dart';
import 'player_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final history = audioProvider.listeningHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Listening History", style: TextStyle(color: AppColors.deepMaroon, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.deepMaroon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: history.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return _buildHistoryItem(context, item);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: AppColors.deepMaroon.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            "No history yet",
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start listening to your favorite stories!",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: item.podcast.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          item.episode.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.deepMaroon),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          item.podcast.author,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_fill, color: AppColors.saffron, size: 30),
          onPressed: () {
            context.read<AudioPlayerProvider>().playEpisode(item.podcast, item.episode);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
          },
        ),
        onTap: () {
          context.read<AudioPlayerProvider>().playEpisode(item.podcast, item.episode);
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayerScreen()));
        },
      ),
    );
  }
}
