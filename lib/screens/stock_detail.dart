import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StockDetailPage extends StatefulWidget {
  final String stockSymbol;
  final String stockName;

  StockDetailPage({required this.stockSymbol, required this.stockName});

  @override
  _StockDetailPageState createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  double? _currentPrice;
  List<Candle> _candles = []; // List to store stock candles
  bool _isLoading = true;
  String _timeframe = "1D"; // Default timeframe (1 Day)
  List<Map<String, dynamic>> _userWatchlists = []; // List of user's watchlists for selection

  @override
  void initState() {
    super.initState();
    _fetchStockData(); // Fetch stock data asynchronously
    _fetchUserWatchlists(); // Fetch the user's watchlists
  }

  // Fetch stock data (current price and historical data)
  Future<void> _fetchStockData() async {
    try {
      // Fetch real-time stock price using Finnhub API
      final priceResponse = await http.get(
        Uri.parse('https://finnhub.io/api/v1/quote?symbol=${widget.stockSymbol}&token=cte78i9r01qt478l82tgcte78i9r01qt478l82u0'),
      );

      if (priceResponse.statusCode == 200) {
        final priceData = jsonDecode(priceResponse.body);
        // Fetch historical data after getting the real-time price
        List<Candle> historicalData = await _fetchHistoricalData(_timeframe);

        setState(() {
          _currentPrice = priceData['c']; // Current price
          _candles = historicalData; // Use historical data for the chart
          _isLoading = false;
        });
      } else {
        print("Failed to load real-time stock price");
      }
    } catch (e) {
      print("Error fetching stock data: $e");
    }
  }

  // Fetch historical data for the stock to plot on the graph
  Future<List<Candle>> _fetchHistoricalData(String timeframe) async {
    final now = DateTime.now();
    final to = now.millisecondsSinceEpoch ~/ 1000;
    final from = to - (timeframe == '1D' ? 86400 : 86400 * 7); // 1 day or 1 week back from now (Unix timestamp)

    try {
      final response = await http.get(
        Uri.parse('https://finnhub.io/api/v1/stock/candle?symbol=${widget.stockSymbol}&resolution=D&from=$from&to=$to&token=cte78i9r01qt478l82tgcte78i9r01qt478l82u0'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Candle> chartData = [];

        // Parse the data into a list of Candles
        for (int i = 0; i < data['t'].length; i++) {
          int timestamp = data['t'][i];
          double open = data['o'][i].toDouble();
          double high = data['h'][i].toDouble();
          double low = data['l'][i].toDouble();
          double close = data['c'][i].toDouble();

          chartData.add(Candle(timestamp: timestamp, open: open, high: high, low: low, close: close));
        }

        return chartData; // Return the parsed chart data
      } else {
        print("Failed to load historical data. Status Code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching historical data: $e");
      return [];
    }
  }

  // Add the stock to the selected user's watchlist (store stock name as a string in the selected watchlist)
  Future<void> _addToWatchlist(String watchlistId) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('watchlists')
            .doc(watchlistId) // Add stock to the selected watchlist
            .collection('stocks')
            .add({
          'name': widget.stockName, // Store stock name
          'symbol': widget.stockSymbol, // Store stock symbol
          'isFavorite': false, // Add an 'isFavorite' field, default to false
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${widget.stockName} added to watchlist")));
      } catch (e) {
        print("Error adding stock to watchlist: $e");
      }
    }
  }

  // Fetch the user's watchlists
  Future<void> _fetchUserWatchlists() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('watchlists')
            .get();

        setState(() {
          _userWatchlists = snapshot.docs
              .map((doc) => {'id': doc.id, 'name': doc['name']})
              .toList();
        });
      } catch (e) {
        print("Error fetching user's watchlists: $e");
      }
    }
  }

  // Show dialog to select watchlist and add stock to it
  void _showAddToWatchlistDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Watchlist'),
          content: _userWatchlists.isEmpty
              ? Text("No watchlists available")
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: _userWatchlists.map((watchlist) {
              return ListTile(
                title: Text(watchlist['name']), // Display watchlist name
                onTap: () {
                  _addToWatchlist(watchlist['id']); // Add stock to the selected watchlist
                  Navigator.of(context).pop(); // Close the dialog after selection
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.stockName)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock info
            Text(widget.stockName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Current Price: \$${_currentPrice?.toStringAsFixed(2)}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 16),

            // Timeframe selector
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: ["1D", "1W", "1M"].map((timeframe) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });

                      List<Candle> historicalData = await _fetchHistoricalData(timeframe);
                      setState(() {
                        _timeframe = timeframe;
                        _candles = historicalData; // Re-fetch and update the graph data
                        _isLoading = false;
                      });
                    },
                    child: Text(timeframe),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // Graph using Syncfusion chart
            SizedBox(
              height: 300, // Adjust the height as needed
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                  minimum: _candles.isNotEmpty ? _candles.map((e) => e.low).reduce((a, b) => a < b ? a : b) : 0,
                  maximum: _candles.isNotEmpty ? _candles.map((e) => e.high).reduce((a, b) => a > b ? a : b) : 0,
                ),
                series: <ChartSeries<Candle, String>>[
                  CandleSeries<Candle, String>(dataSource: _candles,
                    xValueMapper: (Candle candle, _) => DateTime.fromMillisecondsSinceEpoch(candle.timestamp * 1000).toString(),
                    lowValueMapper: (Candle candle, _) => candle.low,
                    highValueMapper: (Candle candle, _) => candle.high,
                    openValueMapper: (Candle candle, _) => candle.open,
                    closeValueMapper: (Candle candle, _) => candle.close,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Add to Watchlist button
            ElevatedButton(
              onPressed: _showAddToWatchlistDialog,
              child: Text("Add to Watchlist"),
            ),
          ],
        ),
      ),
    );
  }
}

// Define the Candle class to represent the data
class Candle {
  final int timestamp;
  final double open;
  final double high;
  final double low;
  final double close;

  Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}
