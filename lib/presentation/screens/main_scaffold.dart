import 'package:audiobook_app/presentation/providers/audio_player_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';

import 'home_screen.dart';
import 'library_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import '../widgets/mini_player.dart';
import '../widgets/subscription_dialog.dart';
import 'login_screen.dart';
import '../providers/auth_provider.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildTabNavigator(0, const HomeScreen()),
      _buildTabNavigator(1, const LibraryScreen()),
      _buildTabNavigator(2, const FavoritesScreen()),
      _buildTabNavigator(3, const ProfileScreen()),
    ];

    // Listen for limit reached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioPlayerProvider>().addListener(_onPlayerStateChanged);
    });
  }

  void _onPlayerStateChanged() {
    if (context.read<AudioPlayerProvider>().limitReached) {
      showDialog(
        context: context,
        builder: (context) => const SubscriptionDialog(),
      );
    }
  }

  @override
  void dispose() {
    // Note: In a real app we'd need to properly remove the listener, 
    // but AudioPlayerProvider lives for app lifetime here.
    super.dispose();
  }

  Widget _buildTabNavigator(int index, Widget root) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => root);
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        final navigator = _navigatorKeys[_selectedIndex]!.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else {
          // If we are at the root of a tab other than Home, switch to Home
          if (_selectedIndex != 0) {
            setState(() => _selectedIndex = 0);
          } else {
            // In a real app, you might want to show a confirm exit dialog here
          }
        }
      },
      child: Scaffold(
        body: Consumer<AudioPlayerProvider>(
          builder: (context, audioProvider, child) {
            final isPlayerActive = audioProvider.currentEpisode != null;
            return Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: isPlayerActive ? 75 : 0, 
                    ),
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _screens,
                    ),
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
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (index == _selectedIndex) {
                // If clicking same tab, pop to root
                _navigatorKeys[index]!.currentState?.popUntil((r) => r.isFirst);
              } else {
                setState(() => _selectedIndex = index);
              }
            },
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
      ),
    );
  }
}
