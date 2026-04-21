import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/story.dart';
import '../providers/audio_player_provider.dart';
import '../providers/story_provider.dart';
import '../widgets/mini_player.dart';
import 'player_screen.dart';

class PodcastDetailScreen extends StatefulWidget {
  final Podcast podcast;
  final List<Podcast>? playlist;

  const PodcastDetailScreen({super.key, required this.podcast, this.playlist});

  @override
  State<PodcastDetailScreen> createState() => _PodcastDetailScreenState();
}

class _PodcastDetailScreenState extends State<PodcastDetailScreen> {
  late ScrollController _scrollController;
  bool _showActionsInAppBar = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      // Show actions when scrolled past 200 pixels
      if (_scrollController.offset > 200 && !_showActionsInAppBar) {
        setState(() => _showActionsInAppBar = true);
      } else if (_scrollController.offset <= 200 && _showActionsInAppBar) {
        setState(() => _showActionsInAppBar = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final isPlayerActive = audioProvider.currentEpisode != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildDescription(context),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.saffron,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Tracks (${widget.podcast.episodes.length})",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.deepMaroon,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final episode = widget.podcast.episodes[index];
                    return GestureDetector(
                      onTap: () {
                        context.read<AudioPlayerProvider>().playEpisode(
                          widget.podcast, 
                          episode,
                          queue: widget.playlist,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PlayerScreen()),
                        );
                      },
                      child: _buildEpisodeItem(context, episode),
                    );
                  },
                  childCount: widget.podcast.episodes.length,
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
              
              // Recommended Section
              _buildRecommendedSection(context),
              
              SliverToBoxAdapter(child: SizedBox(height: isPlayerActive ? 120 : 60)),
            ],
          ),
          
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    
    // Flatten all home sections to find related items
    final allPodcasts = storyProvider.homeSections.values.expand((x) => x).toList();
    final otherPodcasts = allPodcasts
        .where((p) => p.id != widget.podcast.id)
        .take(10)
        .toList();

    if (otherPodcasts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "You might also like",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepMaroon,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: otherPodcasts.length,
              itemBuilder: (context, index) {
                final podcast = otherPodcasts[index];
                return _buildRecommendedCard(context, podcast);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context, Podcast podcast) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PodcastDetailScreen(podcast: podcast),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: podcast.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              podcast.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.deepMaroon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.deepMaroon,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black26,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showActionsInAppBar ? 1.0 : 0.0,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: _showActionsInAppBar 
          ? Text(widget.podcast.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white))
          : null,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'podcast_image_${widget.podcast.id}',
              child: CachedNetworkImage(
                imageUrl: widget.podcast.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.saffron.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.saffron.withOpacity(0.3), width: 0.5),
              ),
              child: Text(
                widget.podcast.category.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.deepMaroon,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            if (!_showActionsInAppBar)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_border_rounded, color: AppColors.deepMaroon, size: 24),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: AppColors.deepMaroon, size: 22),
                    onPressed: () {},
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.podcast.title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.deepMaroon,
                fontSize: 28,
                height: 1.2,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.saffron.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, size: 14, color: AppColors.deepMaroon),
            ),
            const SizedBox(width: 8),
            Text(
              widget.podcast.author,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cream, width: 0.8),
      ),
      child: Text(
        widget.podcast.description,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary.withOpacity(0.65),
              height: 1.5,
              fontSize: 14,
            ),
      ),
    );
  }

  Widget _buildEpisodeItem(BuildContext context, Episode episode) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final isCurrent = audioProvider.currentEpisode?.id == episode.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.saffron.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? AppColors.saffron : AppColors.cream,
          width: 0.8,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.saffron : AppColors.cream,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              isCurrent && audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isCurrent ? Colors.white : AppColors.deepMaroon,
              size: 24,
            ),
          ),
        ),
        title: Text(
          episode.title,
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
            color: isCurrent ? AppColors.deepMaroon : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(episode.duration, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (episode.downloadable)
              IconButton(
                icon: const Icon(Icons.download_for_offline_outlined, color: AppColors.saffron, size: 22),
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Downloading..."), duration: Duration(seconds: 1)),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 20),
              onPressed: () {},
            ),
          ],
        ),
        onTap: () {
          context.read<AudioPlayerProvider>().playEpisode(widget.podcast, episode);
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => const PlayerScreen()),
          );
        },
      ),
    );
  }
}
