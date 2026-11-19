import 'dart:convert'; // jsonEncode / jsonDecode — JANGAN HAPUS
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_model.dart'; // ← EDIT: ganti dengan import model kamu

class FavoriteService {
  // KEY penyimpanan di SharedPreferences — UNIVERSAL, tidak perlu diganti
  static const String _keyFavorites = 'favorites';


  // ══════════════════════════════════════════════════════════════
  static Future<List<ArticleModel>> getFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? favJson = prefs.getString(_keyFavorites);
    if (favJson == null) return []; // belum ada favorite → list kosong
    final List<dynamic> favList = jsonDecode(favJson) as List<dynamic>;
    return favList
        .map((item) => ArticleModel.fromMap(item as Map<String, dynamic>)) // ← EDIT: ganti ArticleModel
        .toList();
  }

  static Future<bool> isFavorite(int id) async {
    final List<ArticleModel> favorites = await getFavorites(); // ← EDIT: ganti ArticleModel
    return favorites.any((item) => item.id == id); // ← EDIT: 'item.id' sesuaikan nama field id-mu
  }


  static Future<void> addFavorite(ArticleModel article) async { // ← EDIT: ganti ArticleModel
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<ArticleModel> favorites = await getFavorites(); // ← EDIT: ganti ArticleModel

    // Cegah duplikat: jika sudah ada, abaikan
    if (favorites.any((item) => item.id == article.id)) return; // ← EDIT: 'item.id', 'article.id'

    favorites.add(article);

    // Simpan ke SharedPreferences sebagai JSON string
    final String encoded = jsonEncode(
      favorites.map((item) => item.toMap()).toList(), // ← EDIT: pastikan model punya toMap()
    );
    await prefs.setString(_keyFavorites, encoded);
  }

  // ══════════════════════════════════════════════════════════════
  // FITUR: HAPUS FAVORITE
  // COPY: method ini — UNIVERSAL setelah ganti ArticleModel
  // ══════════════════════════════════════════════════════════════
  static Future<void> removeFavorite(int id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<ArticleModel> favorites = await getFavorites(); // ← EDIT: ganti ArticleModel

    favorites.removeWhere((item) => item.id == id); // ← EDIT: 'item.id' sesuaikan nama field id

    final String encoded = jsonEncode(
      favorites.map((item) => item.toMap()).toList(),
    );
    await prefs.setString(_keyFavorites, encoded);
  }


  static Future<bool> toggleFavorite(ArticleModel article) async { // ← EDIT: ganti ArticleModel
    final bool alreadyFav = await isFavorite(article.id); // ← EDIT: 'article.id'
    if (alreadyFav) {
      await removeFavorite(article.id); // ← EDIT: 'article.id'
      return false;
    } else {
      await addFavorite(article);
      return true;
    }
  }
}
