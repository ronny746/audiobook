import 'package:audiobook_app/data/models/story.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      backgroundColor: AppColors.background,
      body: storyProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.saffron))
          : storyProvider.errorMessage != null
              ? _buildErrorUI(storyProvider)
              : Stack(
                  children: [
                    // Soft Background Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.saffron.withOpacity(0.05),
                            AppColors.background,
                          ],
                        ),
                      ),
                    ),
                    RefreshIndicator(
                      onRefresh: () => storyProvider.loadStories(),
                      color: AppColors.deepMaroon,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          _buildAppBar(context),
                          
                          // 1. Sleek "Most Listened" Row
                          _buildSectionHeader(context, "Most Listened", () {}),
                          _buildMostListenedRow(context, storyProvider.podcasts),

                          // 2. Featured Carousel (Redesigned)
                          _buildSectionHeader(context, "Featured Stories", () {}),
                          _buildFeaturedCarousel(context, storyProvider.podcasts),
                          
                          // 3. Category Filters
                          _buildCategoryFilters(context, storyProvider),

                          // 4. Trending & Music (Compact Grid)
                          _buildSectionHeader(context, "Explore Music & Tales", () {}),
                          _buildCompactGrid(context, storyProvider.podcasts),

                          const SliverToBoxAdapter(child: SizedBox(height: 120)),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Namaste 🙏",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            "Shravan",
            style: TextStyle(
              color: AppColors.deepMaroon,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Philosopher',
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppColors.deepMaroon),
          onPressed: () {},
        ),
        
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMostListenedRow(BuildContext context, List<Podcast> podcasts) {
    final list = podcasts.take(4).toList();
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final podcast = list[index];
            return GestureDetector(
              onTap: () {
                if (podcast.episodes.isNotEmpty) {
                  context.read<AudioPlayerProvider>().playEpisode(podcast, podcast.episodes.first);
                }
              },
              child: Container(
                width: 240,
                margin: const EdgeInsets.only(right: 16, bottom: 8, top: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.saffron.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepMaroon.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: podcast.imageUrl,
                        width: 70,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            podcast.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.deepMaroon),
                          ),
                          Text(
                            podcast.author,
                            maxLines: 1,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                          const Spacer(),
                          const Icon(Icons.play_circle_fill_rounded, color: AppColors.saffron, size: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
          );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel(BuildContext context, List<Podcast> podcasts) {
    final featured = podcasts.skip(2).take(3).toList();
    if (featured.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 180,
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.85),
          itemCount: featured.length,
          itemBuilder: (context, index) {
            final podcast = featured[index];
            return GestureDetector(
              onTap: () => _handlePodcastTap(context, podcast),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(podcast.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        podcast.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        podcast.category,
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context, StoryProvider provider) {
    final categories = ["All", "Horror", "Romance", "Music", "Spiritual", "Kids", "Mythology"];
    return SliverToBoxAdapter(
      child: Container(
        height: 38,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isFirst = index == 0;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(categories[index]),
                selected: isFirst,
                onSelected: (val) {},
                backgroundColor: Colors.white,
                selectedColor: AppColors.saffron,
                labelStyle: TextStyle(
                  color: isFirst ? Colors.white : AppColors.deepMaroon,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: AppColors.saffron.withOpacity(0.3)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactGrid(BuildContext context, List<Podcast> podcasts) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final podcast = podcasts[index];
            return GestureDetector(
              onTap: () => _handlePodcastTap(context, podcast),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.deepMaroon.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: CachedNetworkImage(imageUrl: podcast.imageUrl, width: double.infinity, fit: BoxFit.cover),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepMaroon),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            podcast.author,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: podcasts.length,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.deepMaroon,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Philosopher',
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.saffron),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI(StoryProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(provider.errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.loadStories(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.saffron),
            child: const Text("Retry", style: TextStyle(color: Colors.white)),
          ),
        ],
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
