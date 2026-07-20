import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  FavoritesService._();
  static final FavoritesService instance = FavoritesService._();
  static const String key = 'favorites';

  Future<List<int>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(key) ?? [];
      return list.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isFavorite(int id) async {
    final list = await getFavorites();
    return list.contains(id);
  }

  Future<bool> toggleFavorite(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(key) ?? [];
      final str = id.toString();
      if (list.contains(str)) {
        list.remove(str);
      } else {
        list.add(str);
      }
      await prefs.setStringList(key, list);
      return true;
    } catch (_) {
      return false;
    }
  }
}
