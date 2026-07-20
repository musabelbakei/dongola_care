import 'dart:async';
import 'package:flutter/material.dart';
import 'category_screen.dart';
import 'coming_soon_screen.dart';
import 'favorites_screen.dart';
import '../widgets/custom_drawer.dart';
import '../utils/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  List<String> get images => AppAssets.facilityImages;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      _pageController.animateToPage(
        (_currentPage + 1) % images.length,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: AppBar(
          title: const Text('دنقلا كير',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: images.length,
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        images[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        // إصلاح طلب #1: إذا فشل تحميل صورة معيّنة (اسم غلط
                        // أو ملف مفقود)، نعرض بديلاً واضحاً بدل شاشة حمراء
                        // أو مساحة فارغة تماماً، مما يسهّل ملاحظة أي صورة
                        // ناقصة تحديداً أثناء الاختبار.
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primaryLight,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.broken_image,
                                  size: 40, color: AppColors.primary),
                              const SizedBox(height: 4),
                              Text('تعذّر تحميل الصورة ${i + 1}',
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textSoft)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'دليلك للوصول إلى الخدمات الصحية في دنقلا',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(images.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: active ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.accent
                              : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('الأقسام',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 10),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                _buildCard(
                    'مستشفيات ومراكز', Icons.local_hospital, AppColors.primary,
                    onTap: () =>
                        _openCategory('مستشفيات ومراكز', 'health_group')),
                _buildCard('صيدليات', Icons.local_pharmacy, AppColors.accent,
                    onTap: () => _openCategory('صيدليات', 'صيدلية')),
                _buildCard('معامل', Icons.science, AppColors.primary,
                    onTap: () => _openCategory('معامل', 'معمل')),
                _buildCard(
                    'سيارات الإسعاف', Icons.local_hospital, AppColors.danger,
                    onTap: () => _openScreen(const ComingSoonScreen())),
                _buildCard(
                    'إرشادات طبية', Icons.medical_information, AppColors.accent,
                    onTap: () => _openScreen(const ComingSoonScreen())),
                _buildCard(
                    'المعدات الطبية', Icons.medical_services, AppColors.primary,
                    onTap: () => _openScreen(const ComingSoonScreen())),
                _buildCard('المفضلة', Icons.favorite, AppColors.danger,
                    onTap: () => _openScreen(const FavoritesScreen())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Color color,
      {required VoidCallback onTap}) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 6),
            Text(title,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _openCategory(String title, String type) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                CategoryScreen(categoryTitle: title, facilityType: type)));
  }

  void _openScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
