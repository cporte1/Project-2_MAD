import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_tracking_app/screens/stock_detail.dart';
import '/models/stock_model.dart';  // Import Stock model

class WatchlistDetailPage extends StatelessWidget {
  final String watchlistId;
  final String watchlistName;

  WatchlistDetailPage({
    required this.watchlistId,
    required this.watchlistName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Watchlist: $watchlistName"),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('watchlists')
            .doc(watchlistId)
            .collection('stocks')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error loading stocks"));
          }

          final stocks = snapshot.data!.docs
              .map((doc) => Stock.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          if (stocks.isEmpty) {
            return Center(child: Text("No stocks in this watchlist"));
          }

          return ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return ListTile(
                title: Text(stock.name),
                subtitle: Text(stock.symbol),
                onTap: () {
                  // Navigate to StockDetailPage and pass the stock's symbol and name
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StockDetailPage(
                        stockSymbol: stock.symbol,
                        stockName: stock.name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
