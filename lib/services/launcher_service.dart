import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class LauncherService {
  LauncherService._();
  static final LauncherService instance = LauncherService._();

  /// إصلاح طلب #3: كانت هذه الدالة تعتمد فقط على رابط google.com/maps
  /// الذي يتطلب متصفح ويب أو تطبيق خرائط مسجَّل لمعالجة روابط https.
  /// على أندرويد، رابط "geo:" هو المعيار الرسمي الذي تلتقطه تطبيقات
  /// الخرائط المثبتة (Google Maps وغيرها) بشكل أوثق، لذلك نجربه أولاً،
  /// ثم نرجع لرابط الويب كخيار احتياطي.
  Future<bool> openGoogleMaps(double lat, double lng) async {
    final Uri geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    final Uri webUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    try {
      if (Platform.isAndroid && await canLaunchUrl(geoUrl)) {
        return await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
      }
      if (await canLaunchUrl(webUrl)) {
        return await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> callPhone(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> openWhatsApp(String phone) async {
    final normalized = _normalizeSudanesePhone(phone);
    final Uri url = Uri.parse('https://wa.me/$normalized');
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendEmail(String email) async {
    final Uri url = Uri(scheme: 'mailto', path: email);
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> openMedicalTipsYoutube() async {
    final Uri url = Uri.parse(
        'https://www.youtube.com/results?search_query=medical+health+tips+arabic');
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  String _normalizeSudanesePhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('249')) return digits;
    if (digits.startsWith('0')) return '249${digits.substring(1)}';
    return digits;
  }
}
