import 'package:audiobook_app/core/theme/app_theme.dart';
import 'package:audiobook_app/data/models/story.dart';
import 'package:audiobook_app/presentation/providers/audio_player_provider.dart';
import 'package:audiobook_app/presentation/screens/player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../widgets/shimmer_loading.dart';
import 'podcast_detail_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: storyProvider.isLoading
          ? _buildShimmerUI(context)
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Your Collections",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: TextField(
                        onSubmitted: (value) => storyProvider.search(value),
                        decoration: const InputDecoration(
                          hintText: "Search Music...",
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: AppColors.deepMaroon),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Categories using real data
                  ...storyProvider.homeSections.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: _buildCategorySection(context, entry.key, entry.value),
                    );
                  }),
                  
                  const SizedBox(height: 30),
                  
                  // Downloads Section (Mock)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.deepMaroon, AppColors.deepMaroon.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.download_done_rounded, color: Colors.white, size: 40),
                          const SizedBox(width: 20),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Offline Music", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                              Text("Coming soon...", style: TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 120), // Bottom padding
                ],
              ),
            ),
    );
  }

  Widget _buildShimmerUI(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          ShimmerLoading(
            child: Container(width: 200, height: 30, color: Colors.white),
          ),
          const SizedBox(height: 20),
          ShimmerLoading(
            child: Container(width: double.infinity, height: 50, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15))),
          ),
          const SizedBox(height: 40),
          Expanded(child: ShimmerLoading.grid()),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String title, List<dynamic> podcasts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          itemCount: podcasts.length,
          itemBuilder: (context, index) {
            final podcast = podcasts[index];
            return GestureDetector(
              onTap: () {
                if (podcast.playType == 'direct') {
                  if (podcast.episodes.isNotEmpty) {
                    context.read<AudioPlayerProvider>().playEpisode(podcast, podcast.episodes.first, queue: podcasts.cast<Podcast>());
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (_) => const PlayerScreen()),
                    );
                  }
                } else {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => PodcastDetailScreen(podcast: podcast)),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(podcast.imageUrl, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            podcast.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            podcast.author,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (100 * index).ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
          },
        ),
      ],
    );
  }
}
