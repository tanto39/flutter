import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Репозиторий избранного
class FavoriteRepository {
  static const _favoritesKey = 'favorites';

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favoritesKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<String>().toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addFavorite(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(symbol)) {
      favorites.add(symbol);
      await prefs.setString(_favoritesKey, jsonEncode(favorites));
    }
  }

  Future<void> removeFavorite(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.remove(symbol);
    await prefs.setString(_favoritesKey, jsonEncode(favorites));
  }
}