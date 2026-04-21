import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../../core/theme/app_theme.dart';
import '../screens/plans_screen.dart';

class SubscriptionDialog extends StatelessWidget {
  const SubscriptionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.saffron.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, color: AppColors.saffron, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              "Free Limit Reached",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.deepMaroon),
            ),
            const SizedBox(height: 12),
            const Text(
              "You've enjoyed your 5 free songs! Subscribe now to get unlimited access to all stories and music.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                context.read<AudioPlayerProvider>().resetLimit();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlansScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepMaroon,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("SEE PLANS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
