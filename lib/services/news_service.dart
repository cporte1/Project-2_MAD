// lib/services/news_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String apiKey = 'cte78i9r01qt478l82tgcte78i9r01qt478l82u0';  // Replace with your Finnhub API key

  // Fetch news articles for a given stock symbol
  Future<List<Map<String, dynamic>>> fetchNewsForSymbol(String symbol) async {
    final url =
        'https://finnhub.io/api/v1/company-news?symbol=$symbol&from=2024-01-01&to=2024-01-01&token=$apiKey'; // Replace date range as needed

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load news for symbol');
    }
  }

  // Fetch trending news
  Future<List<Map<String, dynamic>>> fetchTrendingNews() async {
    final url =
        'https://finnhub.io/api/v1/news?category=general&token=$apiKey';  // Get trending news

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load trending news');
    }
  }
}
