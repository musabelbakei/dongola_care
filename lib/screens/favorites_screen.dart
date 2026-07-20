import 'package:flutter/material.dart';
import '../models/facility_model.dart';
import '../services/db_helper.dart';
import '../services/favorites_service.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_app_bar.dart';
import 'details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FacilityModel> favorites = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final ids = await FavoritesService.instance.getFavorites();
      if (ids.isEmpty) {
        if (!mounted) return;
        setState(() {
          favorites = [];
          loading = false;
        });
        return;
      }
      final all = await DBHelper.instance.getAllFacilities();
      final result = all.where((f) => ids.contains(f.facilityId)).toList();
      if (!mounted) return;
      setState(() {
        favorites = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = 'تعذّر تحميل المفضلة.';
      });
    }
  }

  Future<void> _openDetails(FacilityModel facility) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => DetailsScreen(facility: facility)));
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'المفضلة'),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 56, color: AppColors.danger),
                        const SizedBox(height: 12),
                        Text(errorMessage!),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _load,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : favorites.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_border,
                                size: 64, color: AppColors.textSoft),
                            SizedBox(height: 12),
                            Text('لا توجد مفضلات بعد',
                                style: TextStyle(
                                    fontSize: 16, color: AppColors.textSoft)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: favorites.length,
                        itemBuilder: (_, i) => Card(
                          elevation: 3,
                          shadowColor: AppColors.cardShadow,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            title: Text(favorites[i].facilityName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(favorites[i].addressLine),
                            trailing:
                                const Icon(Icons.arrow_back_ios, size: 16),
                            onTap: () => _openDetails(favorites[i]),
                          ),
                        ),
                      ),
      ),
    );
  }
}
