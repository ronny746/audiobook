import 'package:audiobook_app/presentation/providers/audio_player_provider.dart';
import 'package:audiobook_app/presentation/screens/history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'plans_screen.dart';
import 'notification_screen.dart';
import '../providers/room_sync_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final audioProvider = context.watch<AudioPlayerProvider>();
    final mobileNumber = authProvider.mobileNumber;
    final userData = authProvider.user;
    final subType = userData?['subscriptionType'] ?? 'Free';
    final playCount = userData?['playedSongsCount'] ?? 0;

    // Refresh profile on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider.fetchProfile();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Immersive Gradient Header
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.deepMaroon, Color(0xFF5D0E16), Color(0xFF801525)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Member Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Philosopher',
                          letterSpacing: 1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: subType == 'premium' ? AppColors.saffron : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          subType.toUpperCase(),
                          style: TextStyle(
                            color: subType == 'premium' ? AppColors.deepMaroon : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 26),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10)),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: AppColors.cream,
                            backgroundImage: NetworkImage("https://ui-avatars.com/api/?name=${mobileNumber.substring(mobileNumber.length - 2)}&background=F5C518&color=5D0E16&size=128"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 65),
            
            // 2. User Info
            Text(
              "User ${mobileNumber.substring(mobileNumber.length - 4)}",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.deepMaroon,
                fontFamily: 'Philosopher',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "+91 $mobileNumber",
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            if (subType == 'premium') ...[
              const SizedBox(height: 8),
              Text(
                "Active Plan: ${userData?['activePlanName'] ?? 'Pro'}",
                style: const TextStyle(color: AppColors.saffron, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (userData?['subscriptionExpiry'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Expires: ${DateTime.parse(userData?['subscriptionExpiry']).day}/${DateTime.parse(userData?['subscriptionExpiry']).month}/${DateTime.parse(userData?['subscriptionExpiry']).year}",
                    style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],

            const SizedBox(height: 30),
            
            // 3. Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatDetail("${(playCount * 3.5).toStringAsFixed(1)}m", "Time"),
                    const VerticalDivider(color: Colors.black12, thickness: 1, indent: 10, endIndent: 10),
                    _buildStatDetail("$playCount", "Listened"),
                    const VerticalDivider(color: Colors.black12, thickness: 1, indent: 10, endIndent: 10),
                    _buildStatDetail("${audioProvider.listeningHistory.length}", "Recent"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            
            // 4. Quick Actions (Saved & Downloads)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      Icons.favorite_rounded,
                      "Favorites",
                      "${audioProvider.favoriteEpisodeIds.length} items",
                      Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      Icons.file_download_rounded,
                      "Offline",
                      "${audioProvider.downloadedEpisodeIds.length} items",
                      Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // 5. Menu Items Group
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuRow(
                    Icons.history_rounded, 
                    "Listening History",
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildMenuRow(
                    Icons.workspace_premium_rounded, 
                    "My Subscription",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PlansScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildMenuRow(
                    Icons.notifications_active_rounded, 
                    "Notifications",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                    },
                  ),
                  _buildDivider(),
                  _buildMenuRow(
                    Icons.groups_rounded,
                    "Listen Together",
                    onTap: () {
                      final syncProvider = context.read<RoomSyncProvider>();
                      _showSyncDialog(context, syncProvider);
                    },
                  ),
                  _buildDivider(),
                  _buildMenuRow(Icons.security_rounded, "Privacy & Policy"),
                  _buildDivider(),
                  _buildMenuRow(Icons.help_outline_rounded, "Help Support"),
                  _buildDivider(),
                  _buildMenuRow(
                    Icons.logout_rounded, 
                    "Sign Out", 
                    color: Colors.redAccent,
                    onTap: () async {
                      // 1. Clear player and sensitive data
                      await context.read<AudioPlayerProvider>().clearAllData();
                      // 2. Perform logout and notify auth state
                      await authProvider.logout();
                      // Note: Navigation happens automatically because 
                      // main.dart's Consumer<AuthProvider> will switch to LoginScreen
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            const Text("Version 1.2.4", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDetail(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepMaroon)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Color(0xFFF0F0F0)),
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(IconData icon, String title, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: color ?? AppColors.deepMaroon, size: 22),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: FontWeight.w500, 
          fontSize: 16,
          color: color ?? AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
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
                keyboardType: TextInputType.text,
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

