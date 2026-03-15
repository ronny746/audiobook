import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import 'main_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainScaffold(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.saffron.withOpacity(0.05),
              AppColors.background,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.saffron.withOpacity(0.2),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
              ),
            )
            .animate()
            .scale(duration: 800.ms, curve: Curves.easeOut)
            .shimmer(delay: 1.seconds, duration: 1500.ms, color: AppColors.saffron.withOpacity(0.2)),
            
            const SizedBox(height: 30),
            
            // App Name
            Text(
              "SHRAVAN",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 42,
                letterSpacing: 8,
                color: AppColors.deepMaroon,
                fontWeight: FontWeight.w900,
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
            
            const SizedBox(height: 10),
            
            // Tagline
            Text(
              "Suno Kahaniyan, Buno Yaadein",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.lightBrown,
                letterSpacing: 1.2,
                fontStyle: FontStyle.italic,
              ),
            )
            .animate()
            .fadeIn(delay: 800.ms, duration: 600.ms),
            
            const SizedBox(height: 80),
            
            // Loading Indicator
            const SizedBox(
              width: 40,
              height: 2,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.cream,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.saffron),
              ),
            )
            .animate()
            .fadeIn(delay: 1200.ms)
            .scaleX(duration: 1000.ms),
          ],
        ),
      ),
    );
  }
}
