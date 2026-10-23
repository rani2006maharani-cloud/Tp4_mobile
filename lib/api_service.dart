
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article_model.dart';

class ApiService {
 static const String _apiKey = 'MASUKKAN_API_KEY_KAMU';

  Future<List<Article>> fetchArticles() async {
    final url = Uri.https(
      'newsapi.org',
      '/v2/top-headlines',
      {
        'country': 'id',
        'apiKey': _apiKey,
      },
    );

    try {
      final response = await http.get(url);

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 &&
          data['status'] == 'ok') {
        final List<dynamic> articlesJson =
            data['articles'] as List<dynamic>;

        return articlesJson
            .map((item) => Article.fromJson(
                  item as Map<String, dynamic>,
                ))
            .toList();
      }

      throw Exception(
        'HTTP ${response.statusCode}: '
        '${data['code'] ?? ''} - '
        '${data['message'] ?? 'Gagal mengambil berita'}',
      );
    } catch (e) {
      throw Exception('Gagal memuat berita: $e');
    }
  }
}
