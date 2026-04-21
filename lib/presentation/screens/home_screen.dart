import 'dart:async';
import 'package:audiobook_app/data/models/story.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/story_provider.dart';
import 'notification_screen.dart';
import 'podcast_detail_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/shimmer_loading.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    Future.microtask(() => context.read<StoryProvider>().loadStories()).then((_) {
      _startAutoSlide();
    });
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final storyProvider = context.read<StoryProvider>();
        // Use the first section items for banners
        final banners = storyProvider.homeSections.isNotEmpty 
            ? storyProvider.homeSections.values.first.take(5).toList()
            : [];
        if (banners.isNotEmpty) {
          _currentPage = (_currentPage + 1) % banners.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final audioProvider = context.watch<AudioPlayerProvider>();

    // Listener for extraction errors
    if (audioProvider.extractionError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(audioProvider.extractionError!),
            backgroundColor: AppColors.deepMaroon,
            action: SnackBarAction(
              label: "OK",
              textColor: Colors.white,
              onPressed: () => audioProvider.clearExtractionError(),
            ),
          ),
        ).closed.then((_) => audioProvider.clearExtractionError());
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: storyProvider.isLoading
          ? _buildShimmerUI()
          : storyProvider.errorMessage != null
              ? _buildErrorUI(storyProvider)
              : RefreshIndicator(
                  onRefresh: () => storyProvider.loadStories(),
                  color: AppColors.deepMaroon,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildAppBar(context),
                      
                      // Search Section
                      _buildSearchSection(context, storyProvider),

                      if (storyProvider.searchResults.isNotEmpty) ...[
                        _buildSectionHeader(context, "Search Results", () {}),
                        _buildPosterRow(context, "Results", storyProvider.searchResults),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      ],

                      // Dynamically build sections from backend
                      ...storyProvider.homeSections.entries.map((entry) {
                        final String title = entry.key;
                        final List<Podcast> items = entry.value;

                        if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                        // Special rendering for first section (usually Trending/Featured)
                        if (title == storyProvider.homeSections.keys.first) {
                          return SliverMainAxisGroup(slivers: [
                            _buildHeroSection(context, items),
                            _buildPosterRow(context, title, items),
                          ]);
                        }

                        // Top Shows / Top Stories - specific layouts if needed
                        if (title.contains("Shows") || title.contains("Stories")) {
                          return SliverMainAxisGroup(slivers: [
                            _buildSectionHeader(context, title, () {}),
                            _buildPosterSection(context, items),
                          ]);
                        }

                        // Default list style
                        return SliverMainAxisGroup(slivers: [
                          _buildSectionHeader(context, title, () {}),
                          _buildMostListenedRow(context, items),
                        ]);
                      }),

                      const SliverToBoxAdapter(child: SizedBox(height: 120)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildShimmerUI() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        // Hero Skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerLoading(
              child: Container(
                height: 280,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
        _buildSectionHeader(context, "Trending Now", () {}),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ShimmerLoading(
                  child: Container(width: 140, height: 220, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background.withOpacity(0.8),
      elevation: 0,
      stretch: true,
      title: const Text(
        "SHRAVAN",
        style: TextStyle(
          color: AppColors.deepMaroon,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Philosopher',
          letterSpacing: 2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_active_rounded, color: AppColors.deepMaroon, size: 22),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppColors.deepMaroon, size: 22),
          onPressed: () => context.read<AuthProvider>().logout(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  final List<String> _categories = [
    "All", "Lofi", "Bollywood", "Arijit", "90s Hits", "Romantic", "Chill", "Devotional"
  ];
  String _selectedCategory = "All";

  Widget _buildSearchSection(BuildContext context, StoryProvider provider) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) => provider.search(value),
                decoration: InputDecoration(
                  hintText: "Search Music...",
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.deepMaroon),
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          provider.loadStories();
                        },
                      )
                    : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
          ),
          // Category Row
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = cat);
                      if (cat == "All") {
                        provider.loadStories();
                      } else {
                        provider.search("${cat} songs 2026");
                      }
                    },
                    selectedColor: AppColors.saffron,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.deepMaroon,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, List<Podcast> podcasts) {
    if (podcasts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    
    final banners = podcasts.take(5).toList();

    return SliverToBoxAdapter(
      child: Container(
        height: 280,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) => _currentPage = index,
          itemCount: banners.length,
          itemBuilder: (context, index) {
            final podcast = banners[index];
            return GestureDetector(
              onTap: () => _handlePodcastTap(context, podcast, playlist: banners),
              child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepMaroon.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
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
                            AppColors.deepMaroon.withOpacity(0.8),
                            AppColors.deepMaroon,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 25,
                      left: 20,
                      right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.saffron,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "FEATURED",
                                    style: TextStyle(
                                      color: AppColors.deepMaroon,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  podcast.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Philosopher',
                                  ),
                                ),
                                Text(
                                  podcast.author,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _handlePodcastTap(context, podcast, playlist: banners),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.saffron,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: AppColors.deepMaroon, size: 30),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
          },
        ),
      ),
    );
  }

  Widget _buildPosterRow(BuildContext context, String title, List<Podcast> list) {
    if (list.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final posters = list.reversed.toList();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderContent(context, title, () {}),
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: posters.length,
              itemBuilder: (context, index) {
                final podcast = posters[index];
                return GestureDetector(
                  onTap: () => _handlePodcastTap(context, podcast, playlist: list),
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: AspectRatio(
                                aspectRatio: 1, // Force square fit
                                child: CachedNetworkImage(
                                  imageUrl: podcast.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: Colors.grey[100]),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          podcast.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepMaroon),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContinueListening(BuildContext context) {
    final history = context.watch<AudioPlayerProvider>().listeningHistory;
    if (history.isEmpty) return [];

    return [
      _buildSectionHeader(context, "Continue Listening", () {}),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              final progress = item.totalDuration.inSeconds > 0 
                  ? item.position.inSeconds / item.totalDuration.inSeconds 
                  : 0.0;
              final remaining = item.totalDuration - item.position;
              final remainingText = remaining.inMinutes > 0 
                  ? "${remaining.inMinutes}m left" 
                  : remaining.inSeconds > 0 ? "${remaining.inSeconds}s left" : "Finished";

              return GestureDetector(
                onTap: () {
                  context.read<AudioPlayerProvider>().playEpisode(item.podcast, item.episode, initialPosition: item.position);
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (_) => const PlayerScreen()),
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: item.podcast.imageUrl,
                                width: 140,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: progress.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.saffron,
                                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.episode.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.deepMaroon),
                      ),
                      Text(
                        remainingText,
                        style: const TextStyle(fontSize: 10, color: AppColors.saffron, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ];
  }

  Widget _buildPosterSection(BuildContext context, List<Podcast> podcasts) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 240,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: podcasts.length,
          itemBuilder: (context, index) {
            final podcast = podcasts[index];
            return GestureDetector(
              onTap: () => _handlePodcastTap(context, podcast, playlist: podcasts),
              child: Container(
                width: 150,
                margin: const EdgeInsets.only(right: 16),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 0.7, // Portrait poster
                        child: CachedNetworkImage(
                          imageUrl: podcast.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -25,
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.8),
                          shadows: [
                            Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(2, 2)),
                            const Shadow(color: Colors.white, blurRadius: 2),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms * index).slideX(begin: 0.1, end: 0),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMostListenedRow(BuildContext context, List<Podcast> podcasts) {
    final list = podcasts.take(4).toList();
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final podcast = list[index];
            return GestureDetector(
              onTap: () => _handlePodcastTap(context, podcast, playlist: list),
              child: Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16, bottom: 15, top: 5),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepMaroon.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 85,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deepMaroon.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: CachedNetworkImage(
                            imageUrl: podcast.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[100]),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            podcast.category.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.saffron,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            podcast.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16, 
                              color: AppColors.deepMaroon,
                              height: 1.2,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.deepMaroon.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_arrow_rounded, color: AppColors.deepMaroon, size: 18),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _handlePodcastTap(context, podcast, playlist: podcasts),
                                child: const Text(
                                  "Listen Now",
                                  style: TextStyle(
                                    color: AppColors.deepMaroon,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().slideX(begin: 0.2, end: 0, delay: 50.ms * index).fadeIn();
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
          childAspectRatio: 0.80, // Increased height significantly to fix overflow
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final podcast = podcasts[index];
            return GestureDetector(
              onTap: () => _handlePodcastTap(context, podcast, playlist: podcasts),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.1, // Slightly wider for grid
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: CachedNetworkImage(
                          imageUrl: podcast.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[100]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            podcast.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.deepMaroon,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            podcast.author,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
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
      child: _buildHeaderContent(context, title, onTap),
    );
  }

  Widget _buildHeaderContent(BuildContext context, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.deepMaroon,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Philosopher',
            ),
          ),
          TextButton(
            onPressed: onTap,
            child: const Text(
              "See All",
              style: TextStyle(color: AppColors.saffron, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorUI(StoryProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.saffron, size: 64),
          const SizedBox(height: 16),
          Text(provider.errorMessage!, style: const TextStyle(color: AppColors.deepMaroon, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.loadStories(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepMaroon),
            child: const Text("Retry", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handlePodcastTap(BuildContext context, Podcast podcast, {List<Podcast>? playlist}) {
    if (podcast.playType == 'direct') {
      if (podcast.episodes.isNotEmpty) {
        context.read<AudioPlayerProvider>().playEpisode(
          podcast, 
          podcast.episodes.first,
          queue: playlist,
        );
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => const PlayerScreen()),
        );
      }
    } else {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => PodcastDetailScreen(podcast: podcast)),
      );
    }
  }
}
