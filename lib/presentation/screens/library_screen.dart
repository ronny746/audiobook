import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Your Collections",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
            ),
            const SizedBox(height: 20),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Search stories...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: AppColors.deepMaroon),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Categories
            _buildCategorySection(context, "Recent Plays", [
              "Investing Basics",
              "Retirement Planning",
              "Tax Strategies"
            ]),
            
            const SizedBox(height: 20),
            
            _buildCategorySection(context, "Categories", [
              "Wealth Management",
              "Personal Finance",
              "Market Trends",
              "Dental Practice"
            ]),
            
            const SizedBox(height: 30),
            
            // Downloads Section (Mock)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.deepMaroon, AppColors.deepMaroon.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.download_done_rounded, color: Colors.white, size: 40),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Offline Stories", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text("12 items downloaded", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.saffron.withOpacity(0.1),
                  border: Border.all(color: AppColors.saffron.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  items[index],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepMaroon),
                ),
              ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }
}
