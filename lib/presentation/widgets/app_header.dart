import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.deepMaroon, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            )
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: 22,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        if (!showBack)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: AppColors.saffron.withOpacity(0.15),
              radius: 18,
              child: const Icon(Icons.notifications_none_outlined, size: 20, color: AppColors.deepMaroon),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
