import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const String _key = 'favorite_tools';

  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final values = prefs.getStringList(_key) ?? [];

    return values.toSet();
  }

  static Future<bool> isFavorite(String toolId) async {
    final favorites = await getFavorites();

    return favorites.contains(toolId);
  }

  static Future<void> setFavorite(
      String toolId,
      bool favorite,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = await getFavorites();

    if (favorite) {
      favorites.add(toolId);
    } else {
      favorites.remove(toolId);
    }

    await prefs.setStringList(
      _key,
      favorites.toList(),
    );
  }

  static Future<void> toggleFavorite(
      String toolId,
      ) async {
    final favorite = await isFavorite(toolId);

    await setFavorite(
      toolId,
      !favorite,
    );
  }

  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}