import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_app_bar.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'قريباً'),
        body: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.scale(scale: 0.9 + (0.1 * value), child: child),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.construction,
                    size: 80, color: AppColors.accent),
                const SizedBox(height: 24),
                const Text('🔜 ترقبوا هذه الخدمة قريباً',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                const Text('نعمل على إضافتها في أقرب وقت',
                    style: TextStyle(fontSize: 16, color: AppColors.textSoft)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
