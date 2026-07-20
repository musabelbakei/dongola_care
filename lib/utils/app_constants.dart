import 'package:flutter/material.dart';

/// نظام الألوان الموحّد للتطبيق: أزرق داكن + رمادي، هوية طبية حديثة وهادئة.
/// يجب استخدام AppColors في كل مكان بدل ألوان Material القياسية.
class AppColors {
  static const Color primary = Color(0xFF1B3A5C); // أزرق داكن أساسي
  static const Color primaryDark = Color(0xFF10263F);
  static const Color primaryLight =
      Color(0xFFE7ECF2); // أزرق فاتح جداً للخلفيات
  static const Color accent = Color(0xFF5B7A99); // أزرق رمادي مميز (ثانوي)
  static const Color scaffold =
      Color(0xFFF4F5F7); // رمادي فاتح جداً للخلفية العامة
  static const Color textDark = Color(0xFF1D2939);
  static const Color textSoft =
      Color(0xFF64748B); // رمادي متوسط للنصوص الثانوية
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color cardShadow = Color(0x1A1B3A5C);
  static const Color specialtyChip =
      Color(0xFFEDEFF2); // رمادي فاتح لشرائح التخصصات
}

class AppAssets {
  static const String logo = 'assets/images/1000293964.jpeg';

  static const List<String> facilityImages = [
    'assets/images/1.jpeg',
    'assets/images/2.jpeg',
    'assets/images/3.jpeg',
    'assets/images/4.jpeg',
    'assets/images/5.jpeg',
    'assets/images/6.jpeg',
    'assets/images/7.jpeg',
    'assets/images/8.jpeg',
    'assets/images/9.jpeg',
    'assets/images/10.jpeg',
    'assets/images/11.jpeg',
    'assets/images/12.jpeg',
    'assets/images/13.jpeg',
    'assets/images/14.jpeg',
    'assets/images/15.jpeg',
    'assets/images/16.jpeg',
    'assets/images/17.jpeg',
    'assets/images/18.jpeg',
  ];

  static String getFacilityImageById(int id) {
    if (id < 1 || id > facilityImages.length) return logo;
    return facilityImages[id - 1];
  }
}

class AppStrings {
  static const String appNameAr = 'دنقلا كير';
  static const String appNameEn = 'DONGOLA CARE';
  static const String appTagline = 'دليلك للخدمات الصحية في دنقلا';
}

/// بيانات فريق التطوير المعروضة في القائمة الجانبية / صفحة "عن التطبيق".
/// إصلاح طلب #4: إضافة البريد الإلكتروني بجانب رقم الهاتف لكل عضو.
class DeveloperContact {
  final String name;
  final String phone;
  final String email;
  const DeveloperContact(
      {required this.name, required this.phone, required this.email});
}

class AppTeam {
  static const List<DeveloperContact> members = [
    DeveloperContact(
        name: 'مصعب البكري',
        phone: '0999905257',
        email: 'musabelbakei@gmail.com'),
    DeveloperContact(
        name: 'راشد إسحاق',
        phone: '0923979637',
        email: 'rashidprogrming249@gmail.com'),
    DeveloperContact(
        name: 'محمد عطا', phone: '0129053858', email: 'fenoalonso11@gmail.com'),
    DeveloperContact(
        name: 'كمال خليفة',
        phone: '0111621545',
        email: 'Kamal0100330@gmail.com'),
  ];
}
