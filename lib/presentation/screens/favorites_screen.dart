import 'package:audiobook_app/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/story_provider.dart';
import '../widgets/shimmer_loading.dart';
import 'player_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final storyProvider = context.watch<StoryProvider>();
    
    final favoriteItems = audioProvider.favoriteItems;

    // Sync favorites on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioPlayerProvider>().syncFavoriteItems();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: storyProvider.isLoading
          ? _buildShimmerUI()
          : favoriteItems.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: favoriteItems.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            "Favorites",
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Your most loved stories",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    }
                    
                    final item = favoriteItems[index - 1];
                    final podcast = item.podcast;
                    final episode = item.episode;
                    
                    return GestureDetector(
                      onTap: () {
                        audioProvider.playEpisode(podcast, episode);
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (_) => const PlayerScreen()),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                imageUrl: podcast.imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    episode.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(podcast.author, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () => audioProvider.toggleFavorite(podcast, episode),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 80, color: AppColors.deepMaroon.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text(
            "No Favorites yet",
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Heart your favorite stories to find them here!"),
        ],
      ),
    );
  }

  Widget _buildShimmerUI() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ShimmerLoading(child: Container(width: 150, height: 30, color: Colors.white)),
          const SizedBox(height: 10),
          ShimmerLoading(child: Container(width: 250, height: 15, color: Colors.white)),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ShimmerLoading(
                  child: Container(width: double.infinity, height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
