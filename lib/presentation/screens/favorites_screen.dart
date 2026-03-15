import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for favorites
    final favStories = [
      {
        "title": "#722: Is Specializing Worth It?",
        "author": "Dentist Advisors",
        "image": "https://ik.imagekit.io/vurtux/tr:n-app_thumbnail_large/https://static.libsyn.com/p/assets/7/7/5/8/775830f7d20d3d7816c3140a3186d450/DMS_Episode_Artwork-20250812-zwmyjjsel2-20251211-5842yimtyh.png"
      },
      {
        "title": "#718: A Decade of The DMS",
        "author": "Dentist Advisors",
        "image": "https://ik.imagekit.io/vurtux/tr:n-app_thumbnail_large/https://static.libsyn.com/p/assets/4/9/0/7/4907794c17cdb12c16c3140a3186d450/DMS_Episode_Artwork-20250812-zwmyjjsel2-20251201-idfoep3qtg.png"
      }
    ];

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        itemCount: favStories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Favorites",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  "Your most loved stories",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 30),
              ],
            );
          }
          
          final story = favStories[index - 1];
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: story['image']!,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story['title']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(story['author']!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                const Icon(Icons.favorite, color: Colors.red),
              ],
            ),
          ).animate().fadeIn(delay: (200 * index).ms).slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }
}
