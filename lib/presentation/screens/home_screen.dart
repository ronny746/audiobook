import 'package:audiobook_app/data/models/story.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/story_provider.dart';
import '../widgets/podcast_card.dart';
import 'podcast_detail_screen.dart';
import '../providers/audio_player_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<StoryProvider>().loadStories());
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();

    return Scaffold(
      body: storyProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.saffron))
          : storyProvider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(storyProvider.errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => storyProvider.loadStories(),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.saffron),
                        child: const Text("Retry", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => storyProvider.loadStories(),
                  color: AppColors.saffron,
                  child: CustomScrollView(
                    slivers: [
                      // Welcome Text
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Discover Stories",
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Timeless Indian tales for your soul",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // ... (rest of the slivers)
                      if (storyProvider.podcasts.isNotEmpty)
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              itemCount: storyProvider.podcasts.take(3).length,
                              itemBuilder: (context, index) {
                                final podcast = storyProvider.podcasts[index];
                                return _buildFeaturedCard(context, podcast);
                              },
                            ),
                          ),
                        ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Top Podcasts",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppColors.deepMaroon,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text("See All", style: TextStyle(color: AppColors.saffron)),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final podcast = storyProvider.podcasts[index];
                              return PodcastCard(
                                podcast: podcast,
                                onTap: () => _handlePodcastTap(context, podcast),
                              );
                            },
                            childCount: storyProvider.podcasts.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Podcast podcast) {
    return GestureDetector(
      onTap: () => _handlePodcastTap(context, podcast),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: DecorationImage(
            image: NetworkImage(podcast.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepMaroon.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.saffron,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  podcast.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                podcast.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _handlePodcastTap(BuildContext context, Podcast podcast) {
    if (podcast.playType == 'detail') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PodcastDetailScreen(podcast: podcast)),
      );
    } else {
      if (podcast.episodes.isNotEmpty) {
        context.read<AudioPlayerProvider>().playEpisode(podcast, podcast.episodes.first);
      }
    }
  }
}
