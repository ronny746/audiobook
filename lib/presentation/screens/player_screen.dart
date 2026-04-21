import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/audio_player_widget.dart';
import '../providers/room_sync_provider.dart';
import '../../data/models/story.dart';
import '../providers/auth_provider.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool showLyrics = false;

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final podcast = audioProvider.currentPodcast;
    final episode = audioProvider.currentEpisode;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
  

    if (podcast == null || episode == null) {
      return const Scaffold(body: Center(child: Text("No episode selected")));
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient with subtle image blur
          Positioned.fill(
            child: Container(
              color: AppColors.background,
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CachedNetworkImage(
                imageUrl: podcast.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withOpacity(0.8),
                    AppColors.background.withOpacity(0.9),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            size: 36),
                        color: AppColors.deepMaroon,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "NOW PLAYING",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: AppColors.deepMaroon.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              podcast.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepMaroon,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<RoomSyncProvider>(
                        builder: (context, syncProvider, _) {
                          return IconButton(
                            onPressed: () => _showSyncDialog(context, syncProvider),
                            icon: Icon(
                              syncProvider.isConnected 
                                ? Icons.people_rounded 
                                : Icons.people_outline_rounded,
                              color: syncProvider.isConnected ? AppColors.saffron : AppColors.deepMaroon,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_horiz_rounded),
                        color: AppColors.deepMaroon,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: showLyrics
                        ? _buildLyricsView(episode)
                        : _buildPlayerView(podcast, episode, screenHeight),
                  ),
                ),

                // Player Controls Section
                _buildControlsSection(podcast, episode, audioProvider),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Loading Overlay
          if (audioProvider.isExtracting)
            Container(
              color: Colors.black.withOpacity(0.6),
              child: BackdropFilter(
                filter: ColorFilter.mode(
                    Colors.black.withOpacity(0.2), BlendMode.darken),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      color: AppColors.saffron,
                      strokeWidth: 5,
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOut),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerView(
      Podcast podcast, Episode episode, double screenHeight) {
    return Column(
      key: const ValueKey("player_view"),
      children: [
        const Spacer(flex: 1),
        // Cover Art
        Center(
          child: Hero(
            tag: 'podcast_image_${podcast.id}',
            child: Container(
              width: screenHeight * 0.32,
              height: screenHeight * 0.32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CachedNetworkImage(
                  imageUrl: podcast.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOut).fadeIn(),

        const Spacer(flex: 1),

        // Metadata
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                episode.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepMaroon,
                  height: 1.2,
                  fontFamily: 'Philosopher',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                podcast.author.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: AppColors.deepMaroon.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.saffron.withOpacity(0.3)),
                ),
                child: Text(
                  podcast.category,
                  style: const TextStyle(
                      color: AppColors.saffron,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildLyricsView(Episode episode) {
    return Container(
      key: const ValueKey("lyrics_view"),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "LYRICS",
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
              color: AppColors.deepMaroon,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                episode.lyrics ?? "Lyrics not available for this episode.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepMaroon.withOpacity(0.9),
                  height: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1, end: 0).fadeIn();
  }

  Widget _buildControlsSection(
      Podcast podcast, Episode episode, AudioPlayerProvider audioProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.deepMaroon.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            AudioPlayerWidget(audioUrl: episode.audioUrl),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIconButton(
                  audioProvider.isFavorite(episode.id)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  () => audioProvider.toggleFavorite(podcast, episode),
                  color: audioProvider.isFavorite(episode.id)
                      ? Colors.redAccent
                      : null,
                ),
                _buildIconButton(Icons.share_outlined, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sharing episode...")),
                  );
                }),
                GestureDetector(
                  onTap: () => setState(() => showLyrics = !showLyrics),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: showLyrics
                          ? AppColors.deepMaroon
                          : AppColors.deepMaroon.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lyrics_rounded,
                            size: 18,
                            color: showLyrics
                                ? Colors.white
                                : AppColors.deepMaroon),
                        const SizedBox(width: 8),
                        Text(
                          "LYRICS",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: showLyrics
                                ? Colors.white
                                : AppColors.deepMaroon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildIconButton(
                  audioProvider.isDownloaded(episode.id)
                      ? Icons.file_download_done_rounded
                      : Icons.file_download_outlined,
                  () => audioProvider.toggleDownload(episode),
                  color: audioProvider.isDownloaded(episode.id)
                      ? Colors.green
                      : null,
                ),
                _buildIconButton(Icons.more_horiz_rounded, () {
                  _showMoreOptions(context, episode);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, Episode episode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.deepMaroon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              episode.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.deepMaroon),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            _buildOptionTile(Icons.timer_outlined, "Sleep Timer"),
            _buildOptionTile(Icons.speed_rounded, "Playback Speed"),
            _buildOptionTile(Icons.playlist_add_rounded, "Add to Playlist"),
            _buildOptionTile(Icons.info_outline_rounded, "Episode Credits"),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.deepMaroon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon,
          color: color ?? AppColors.deepMaroon.withOpacity(0.7), size: 24),
    );
  }

  void _showSyncDialog(BuildContext context, RoomSyncProvider syncProvider) {
    final TextEditingController controller = TextEditingController();
    final auth = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Listen Together", style: TextStyle(color: AppColors.deepMaroon, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Sync your playback with friends in real-time.", style: TextStyle(fontSize: 12)),
            const SizedBox(height: 20),
            if (syncProvider.isConnected) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text("In Room: ${syncProvider.roomId}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  syncProvider.leaveRoom();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                child: const Text("Leave Room"),
              ),
            ] else ...[
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Enter Room ID",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      syncProvider.joinRoom(controller.text, auth.user?['_id'] ?? "anonymous");
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepMaroon, foregroundColor: Colors.white),
                  child: const Text("Join / Create Room"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
