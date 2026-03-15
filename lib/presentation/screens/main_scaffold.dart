import 'package:audiobook_app/presentation/providers/audio_player_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_header.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import '../widgets/mini_player.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: "Shravan"),
      body: Consumer<AudioPlayerProvider>(
        builder: (context, audioProvider, child) {
          final isPlayerActive = audioProvider.currentEpisode != null;
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: isPlayerActive ? 85 : 0),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _screens,
                ),
              ),
              if (isPlayerActive)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: MiniPlayer(),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore, color: AppColors.deepMaroon),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories, color: AppColors.deepMaroon),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded, color: AppColors.deepMaroon),
              label: 'Saved',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              selectedIcon: Icon(Icons.account_circle, color: AppColors.deepMaroon),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
