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
              : RefreshIndicator(
                  onRefresh: () => storyProvider.loadStories(),
                  color: AppColors.saffron,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildAppBar(context),
                      
                      // 1. Most Listened (Dark Player Style Row)
                      _buildSectionHeader(context, "Most Listened", () {}),
                      _buildTopListenedSection(context, storyProvider.podcasts),

                      // 2. Featured Hero Carousel (Top Picks)
                      _buildFeaturedCarousel(context, storyProvider.podcasts),
                      
                      // 3. Category Quick Filters
                      _buildCategoryFilters(context, storyProvider),

                      // 4. New & Trending (Horizontal Square Cards)
                      _buildSectionHeader(context, "New & Trending", () {}),
                      _buildTrendingSection(context, storyProvider.podcasts),

                      // 5. Music & Meditation (Grid Style)
                      _buildSectionHeader(context, "Music & Meditation", () {}),
                      _buildMusicGrid(context, storyProvider.podcasts.where((p) => p.category == 'Music' || p.category == 'Spiritual').toList()),

                      // 6. For Kids (Circular Cards)
                      _buildSectionHeader(context, "Children's Corner", () {}),
                      _buildKidsSection(context, storyProvider.podcasts.where((p) => p.category == 'Kids').toList()),

                      // 7. Horror Specials (Detailed List)
                      _buildSectionHeader(context, "Midnight Horror", () {}),
                      _buildHorrorList(context, storyProvider.podcasts.where((p) => p.category == 'Horror').toList()),

                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Namaste 🙏",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  "Shravan",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 26,
                        color: AppColors.deepMaroon,
                      ),
                ),
              ],
            ),
            Row(
              children: [
                _buildRoundIconButton(context, Icons.search_rounded),
                const SizedBox(width: 12),
                Stack(
                  children: [
                    _buildRoundIconButton(context, Icons.notifications_none_rounded),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          "2",
                          style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundIconButton(BuildContext context, IconData icon) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      child: IconButton(
        icon: Icon(icon, color: AppColors.deepMaroon, size: 20),
        onPressed: () {},
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildTopListenedSection(BuildContext context, List<Podcast> podcasts) {
    if (podcasts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    return SliverToBoxAdapter(
      child: Container(
        height: 155,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: podcasts.length,
          itemBuilder: (context, index) {
            final podcast = podcasts[index];
            return _buildPlayerStyleCard(context, podcast);
          },
        ),
      ),
    );
  }

  Widget _buildPlayerStyleCard(BuildContext context, Podcast podcast) {
    return GestureDetector(
      onTap: () {
        if (podcast.episodes.isNotEmpty) {
          context.read<AudioPlayerProvider>().playEpisode(podcast, podcast.episodes.first);
        }
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16, bottom: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.deepMaroon,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepMaroon.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.graphic_eq_rounded, color: AppColors.saffron, size: 12),
                const SizedBox(width: 6),
                Text(
                  "MOST STREAMED",
                  style: TextStyle(
                    color: AppColors.saffron.withOpacity(0.9),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              podcast.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              podcast.author,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.saffron,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.play_circle_fill_rounded, color: AppColors.saffron, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel(BuildContext context, List<Podcast> podcasts) {
    final featured = podcasts.take(3).toList();
    if (featured.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Container(
        height: 240,
        margin: const EdgeInsets.only(top: 10),
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.9),
          itemCount: featured.length,
          itemBuilder: (context, index) {
            final podcast = featured[index];
            return _buildHeroCard(context, podcast);
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, Podcast podcast) {
    return GestureDetector(
      onTap: () => _handlePodcastTap(context, podcast),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepMaroon.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: podcast.imageUrl,
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
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
                        podcast.category.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      podcast.title,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      podcast.author,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildCategoryFilters(BuildContext context, StoryProvider provider) {
    final categories = ["All", "Horror", "Romance", "Music", "Spiritual", "Kids", "Mythology"];
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = index == 0; // Just for UI demo
            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(categories[index]),
                selected: isSelected,
                onSelected: (val) {},
                backgroundColor: Colors.white,
                selectedColor: AppColors.deepMaroon,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.deepMaroon,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(color: AppColors.deepMaroon.withOpacity(0.1)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.deepMaroon,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
            ),
            TextButton(
              onPressed: onTap,
              child: const Text("See All", style: TextStyle(color: AppColors.saffron, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(BuildContext context, List<Podcast> podcasts) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: podcasts.length,
          itemBuilder: (context, index) {
            final podcast = podcasts[index];
            return _buildSquareCard(context, podcast);
          },
        ),
      ),
    );
  }

  Widget _buildSquareCard(BuildContext context, Podcast podcast) {
    return GestureDetector(
      onTap: () => _handlePodcastTap(context, podcast),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CachedNetworkImage(
                imageUrl: podcast.imageUrl,
                height: 140,
                width: 140,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMusicGrid(BuildContext context, List<Podcast> podcasts) {
    if (podcasts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final podcast = podcasts[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: CachedNetworkImage(imageUrl: podcast.imageUrl, width: double.infinity, fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          podcast.title,
                          maxLines: 1,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepMaroon),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.music_note_rounded, size: 10, color: AppColors.saffron),
                            const SizedBox(width: 4),
                            Text(
                              podcast.actionLabel,
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: (index * 100).ms);
          },
          childCount: podcasts.length,
        ),
      ),
    );
  }

  Widget _buildKidsSection(BuildContext context, List<Podcast> podcasts) {
    if (podcasts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: podcasts.length,
          itemBuilder: (context, index) {
            final podcast = podcasts[index];
            return GestureDetector(
              onTap: () => _handlePodcastTap(context, podcast),
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(podcast.imageUrl),
                      backgroundColor: AppColors.cream,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      podcast.category,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.deepMaroon),
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

  Widget _buildHorrorList(BuildContext context, List<Podcast> podcasts) {
    if (podcasts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final podcast = podcasts[index];
            return PodcastCard(
              podcast: podcast,
              onTap: () => _handlePodcastTap(context, podcast),
            );
          },
          childCount: podcasts.length,
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
