import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Profile Info
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.saffron,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.cream,
                          child: Icon(Icons.person, size: 60, color: AppColors.deepMaroon),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppColors.deepMaroon, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text("Rohit G.", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text("rohit@example.com", style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(context, "12", "Stories"),
                  _buildStat(context, "4.5h", "Listening"),
                  _buildStat(context, "5", "Badges"),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Settings List
            _buildSettingItem(Icons.history, "Listening History"),
            _buildSettingItem(Icons.settings_outlined, "App Settings"),
            _buildSettingItem(Icons.help_outline, "Help & Support"),
            _buildSettingItem(Icons.logout, "Logout", isLast: true),
            
            const SizedBox(height: 40),
            
            // Version Info
            const Text("Version 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepMaroon)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {bool isLast = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.deepMaroon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}
