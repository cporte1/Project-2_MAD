// lib/services/stock_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class StockService {
  final String apiKey = 'cte78i9r01qt478l82tgcte78i9r01qt478l82u0';  // Replace with your Finnhub API key

  // Fetch real-time stock price
  Future<Map<String, dynamic>> fetchStockPrice(String symbol) async {
    final url =
        'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey';  // API URL for stock price

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);  // Returns the stock data as a map
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  // Fetch biggest movers (e.g., stocks with the highest percentage change)
  Future<List<Map<String, dynamic>>> fetchBiggestMovers() async {
    final url =
        'https://finnhub.io/api/v1/stock/symbol?exchange=US&token=$apiKey';  // Get list of symbols

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Fetch data for a subset of the symbols (replace with actual criteria for biggest movers)
      List<Map<String, dynamic>> biggestMovers = [];
      for (var symbol in data.take(10)) {  // Example: Taking the first 10 stocks
        final stockData = await fetchStockPrice(symbol['symbol']);
        biggestMovers.add({
          'symbol': symbol['symbol'],
          'price': stockData['c'],
          'name': symbol['description'],  // Using 'description' as a placeholder for company name
        });
      }
      return biggestMovers;
    } else {
      throw Exception('Failed to load biggest movers');
    }
  }

  // Fetch popular stocks (using a predefined list for demo)
  Future<List<Map<String, dynamic>>> fetchPopularStocks() async {
    // For demo purposes, we will fetch real-time data for a static set of popular stocks
    List<String> popularSymbols = ['AAPL', 'TSLA', 'GOOG', 'MSFT', 'AMZN'];  // Example popular stocks
    List<Map<String, dynamic>> popularStocks = [];

    for (var symbol in popularSymbols) {
      final stockData = await fetchStockPrice(symbol);
      popularStocks.add({
        'symbol': symbol,
        'price': stockData['c'],
        'name': symbol,  // Placeholder for company name
      });
    }

    return popularStocks;
  }
}
