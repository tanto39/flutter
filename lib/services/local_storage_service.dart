import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _favoritesKey = 'favorites';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> addFavorite(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(symbol)) {
      favorites.add(symbol);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  Future<void> removeFavorite(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.remove(symbol);
    await prefs.setStringList(_favoritesKey, favorites);
  }
}