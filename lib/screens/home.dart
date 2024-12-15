// lib/screens/home.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/stock_service.dart';  // Service for Finnhub API
import '/models/stock_model.dart';  // Stock model for holding stock data
import 'stock_detail.dart'; // Stock detail page import

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Stock> _watchlistStocks = [];  // List of stocks from the favorite watchlist
  String? favoriteWatchlistId;        // Favorite watchlist ID
  List<Map<String, dynamic>> _biggestMovers = [];
  List<Map<String, dynamic>> _popularStocks = [];

  bool _showMoreBiggestMovers = false;
  bool _showMorePopularStocks = false;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteWatchlist();  // Fetch the favorite watchlist
    _fetchBiggestMovers();  // Replace with static data
    _fetchPopularStocks();  // Replace with static data
  }

  // Fetch the user's favorite watchlist from Firestore
  Future<void> _fetchFavoriteWatchlist() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Fetch all watchlists and find the one marked as favorite
      final watchlistsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('watchlists')
          .where('isFavorite', isEqualTo: true) // Find the favorite watchlist
          .get();

      if (watchlistsSnapshot.docs.isNotEmpty) {
        final favoriteWatchlistDoc = watchlistsSnapshot.docs.first;
        setState(() {
          favoriteWatchlistId = favoriteWatchlistDoc.id;  // Store favorite watchlist ID
        });

        // Fetch stocks from the favorite watchlist
        final stocksSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('watchlists')
            .doc(favoriteWatchlistId)
            .collection('stocks')
            .get();

        setState(() {
          _watchlistStocks = stocksSnapshot.docs
              .map((doc) => Stock.fromMap(doc.data() as Map<String, dynamic>))
              .toList();
        });
      } else {
        print("No favorite watchlist found.");
      }
    }
  }

  // Fetch biggest movers - Static data for testing
  Future<void> _fetchBiggestMovers() async {
    setState(() {
      _biggestMovers = [
        {'name': 'Apple', 'symbol': 'AAPL', 'price': 150.0},
        {'name': 'Tesla', 'symbol': 'TSLA', 'price': 650.0},
        {'name': 'Amazon', 'symbol': 'AMZN', 'price': 3400.0},
        {'name': 'Microsoft', 'symbol': 'MSFT', 'price': 280.0},
        {'name': 'Google', 'symbol': 'GOOG', 'price': 2730.0},
      ];
      print("Fetched biggest movers: ${_biggestMovers.length} stocks");
    });
  }

  // Fetch popular stocks - Static data for testing
  Future<void> _fetchPopularStocks() async {
    setState(() {
      _popularStocks = [
        {'name': 'Meta', 'symbol': 'META', 'price': 330.0},
        {'name': 'Netflix', 'symbol': 'NFLX', 'price': 580.0},
        {'name': 'Adobe', 'symbol': 'ADBE', 'price': 670.0},
        {'name': 'Nvidia', 'symbol': 'NVDA', 'price': 210.0},
        {'name': 'Intel', 'symbol': 'INTC', 'price': 60.0},
      ];
      print("Fetched popular stocks: ${_popularStocks.length} stocks");
    });
  }

  // Limit the number of stocks displayed (5)
  List<Map<String, dynamic>> _getLimitedStocks(List<Map<String, dynamic>> stocks, bool showAll) {
    return showAll ? stocks : stocks.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button if any
        title: null, // No title in the app bar
        elevation: 0, // Removes the shadow from the AppBar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Your Watchlist Section
              _buildSectionTitle("Your Favorite Watchlist"),
              _buildWatchlistSection(),

              // Biggest Movers Section
              _buildSectionTitle("Biggest Movers"),
              _buildBiggestMoversSection(),

              // Popular Stocks Section
              _buildSectionTitle("Popular Stocks"),
              _buildPopularStocksSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Watchlist Section - Modified to show stocks from the favorite watchlist
  Widget _buildWatchlistSection() {
    return _watchlistStocks.isEmpty
        ? Center(child: Text("No stocks in your favorite watchlist"))
        : Column(
      children: _watchlistStocks.map((stock) {
        return ListTile(
          title: Text(stock.name),
          subtitle: Text(stock.symbol),
          trailing: Text("\$${stock.price.toStringAsFixed(2)}"),
          onTap: () {
            _navigateToStockDetail(stock.symbol, stock.name);
          },
        );
      }).toList(),
    );
  }

  // Biggest Movers Section
  Widget _buildBiggestMoversSection() {
    List<Map<String, dynamic>> limitedBiggestMovers = _getLimitedStocks(_biggestMovers, _showMoreBiggestMovers);

    return Column(
      children: [
        Column(
          children: limitedBiggestMovers.map((stock) {
            return ListTile(
              title: Text(stock['name']),
              subtitle: Text(stock['symbol']),
              trailing: Text("\$${stock['price']}"),
              onTap: () {
                _navigateToStockDetail(stock['symbol'], stock['name']);
              },
            );
          }).toList(),
        ),
        if (_biggestMovers.length > 5)
          TextButton(
            onPressed: () {
              setState(() {
                _showMoreBiggestMovers = !_showMoreBiggestMovers;
              });
            },
            child: Text(_showMoreBiggestMovers ? "Show Less" : "View More..."),
          ),
      ],
    );
  }

  // Popular Stocks Section
  Widget _buildPopularStocksSection() {
    List<Map<String, dynamic>> limitedPopularStocks = _getLimitedStocks(_popularStocks, _showMorePopularStocks);

    return Column(
      children: [
        Column(
          children: limitedPopularStocks.map((stock) {
            return ListTile(
              title: Text(stock['name']),
              subtitle: Text(stock['symbol']),
              trailing: Text("\$${stock['price']}"),
              onTap: () {
                _navigateToStockDetail(stock['symbol'], stock['name']);
              },
            );
          }).toList(),
        ),
        if (_popularStocks.length > 5)
          TextButton(
            onPressed: () {
              setState(() {
                _showMorePopularStocks = !_showMorePopularStocks;
              });
            },
            child: Text(_showMorePopularStocks ? "Show Less" : "View More..."),
          ),
      ],
    );
  }

  // Navigate to Stock Detail Page
  void _navigateToStockDetail(String symbol, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailPage(stockSymbol: symbol, stockName: name),
      ),
    );
  }
}
