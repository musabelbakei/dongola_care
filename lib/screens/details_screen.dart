import 'package:flutter/material.dart';
import '../models/facility_model.dart';
import '../services/launcher_service.dart';
import '../services/favorites_service.dart';
import '../utils/app_constants.dart';
import '../widgets/custom_app_bar.dart';

class DetailsScreen extends StatefulWidget {
  final FacilityModel facility;
  const DetailsScreen({super.key, required this.facility});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final result =
        await FavoritesService.instance.isFavorite(widget.facility.facilityId);
    if (!mounted) return;
    setState(() => isFavorite = result);
  }

  Future<void> _toggleFavorite() async {
    final success = await FavoritesService.instance
        .toggleFavorite(widget.facility.facilityId);
    if (!mounted) return;
    if (success) {
      setState(() => isFavorite = !isFavorite);
    } else {
      _showSnack('تعذّر تحديث المفضلة، حاول مرة أخرى');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openMap() async {
    final f = widget.facility;
    if (f.latitude == null || f.longitude == null) {
      _showSnack('لا توجد إحداثيات مسجّلة لهذه المنشأة');
      return;
    }
    final success = await LauncherService.instance
        .openGoogleMaps(f.latitude!, f.longitude!);
    if (!success)
      _showSnack('تعذّر فتح الخريطة، تأكد من وجود تطبيق خرائط على جهازك');
  }

  Future<void> _callPhone(String phone) async {
    final success = await LauncherService.instance.callPhone(phone);
    if (!success) {
      _showSnack('تعذّر إجراء الاتصال');
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.facility;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'تفاصيل المنشأة',
          actions: [
            IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white),
              onPressed: _toggleFavorite,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Hero(
                  tag: 'facility_image_${f.facilityId}',
                  child: Image.asset(
                    f.imagePath,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.local_hospital,
                          size: 64, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(f.facilityName,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(height: 6),
              Text('النوع: ${f.facilityType}',
                  style:
                      const TextStyle(fontSize: 16, color: AppColors.textSoft)),
              const Divider(height: 30, thickness: 1.5),

              // طلب #5: التأكد من ظهور كل الحقول بدون استثناء، حتى لو كانت
              // القيمة "غير متوفر" — لا نُخفي أي صف بصمت.
              _infoRow(Icons.phone, 'الهاتف', f.phone ?? 'غير متوفر',
                  isPhone: true),
              _infoRow(Icons.access_time, 'ساعات العمل',
                  f.workingHours ?? 'غير متوفر'),
              _infoRow(Icons.business, 'القطاع', f.sector ?? 'غير متوفر'),
              _infoRow(
                  Icons.location_city, 'الحي', f.neighborhood ?? 'غير متوفر'),
              _infoRow(Icons.signpost, 'الشارع', f.street ?? 'غير متوفر'),
              _infoRow(Icons.place, 'معالم بارزة', f.landmark ?? 'غير متوفر'),
              const Divider(height: 30, thickness: 1.5),

              const Text('الخدمات:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              f.services.isNotEmpty
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: f.services
                          .map((s) => Chip(
                              label: Text(s),
                              backgroundColor: AppColors.primaryLight))
                          .toList(),
                    )
                  : const Text('لا توجد خدمات مسجّلة',
                      style: TextStyle(color: AppColors.textSoft)),
              const SizedBox(height: 16),

              const Text('التخصصات:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              f.specialties.isNotEmpty
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: f.specialties
                          .map((s) => Chip(
                              label: Text(s),
                              backgroundColor: AppColors.specialtyChip))
                          .toList(),
                    )
                  : const Text('لا توجد تخصصات مسجّلة',
                      style: TextStyle(color: AppColors.textSoft)),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openMap,
                  icon: const Icon(Icons.map),
                  label: const Text('فتح الموقع على الخريطة',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value,
      {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(
              width: 100,
              child: Text('$title:',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: isPhone && value != 'غير متوفر'
                ? InkWell(
                    onTap: () => _callPhone(value),
                    child: Text(value,
                        style: const TextStyle(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline)),
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }
}
