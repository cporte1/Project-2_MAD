import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageWatchlistPage extends StatefulWidget {
  @override
  _ManageWatchlistPageState createState() => _ManageWatchlistPageState();
}

class _ManageWatchlistPageState extends State<ManageWatchlistPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> watchlists = []; // List to hold the user's watchlists

  @override
  void initState() {
    super.initState();
    _fetchWatchlists();
  }

  // Fetch the watchlists for the current user from Firestore
  Future<void> _fetchWatchlists() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('watchlists')
            .get();

        setState(() {
          watchlists = snapshot.docs
              .map((doc) {
            return {
              'id': doc.id,
              'name': doc.data()['name'] ?? 'Untitled Watchlist',
              'isFavorite': doc.data()['isFavorite'] ?? false, // Fetching the 'isFavorite' field
            };
          })
              .toList();
        });
      } catch (e) {
        print("Error fetching watchlists: $e");
      }
    }
  }

  // Add a new watchlist
  Future<void> _addWatchlist() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      String newWatchlistName = await _showWatchlistDialog('Create New Watchlist');
      if (newWatchlistName.isNotEmpty) {
        try {
          // Add the new watchlist to Firestore with isFavorite set to false by default
          DocumentReference watchlistRef = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('watchlists')
              .add({
            'name': newWatchlistName,  // Save the watchlist name
            'isFavorite': false, // Set isFavorite to false by default
          });

          // Create an empty 'stocks' subcollection for the newly created watchlist
          await watchlistRef.collection('stocks').add({}); // Empty stock document

          _fetchWatchlists();  // Refresh the list of watchlists
        } catch (e) {
          print("Error adding watchlist: $e");
        }
      }
    }
  }

  // Show the dialog to input a new watchlist name
  Future<String> _showWatchlistDialog(String title, {String initialName = ''}) async {
    TextEditingController _controller = TextEditingController(text: initialName);
    String name = '';

    await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Watchlist Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                name = _controller.text;
                Navigator.of(context).pop(name);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(name); // Just close the dialog if canceled
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    return name;
  }

  // Mark a watchlist as favorite and update Firestore
  Future<void> _markAsFavorite(String watchlistId) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Mark the selected watchlist as favorite
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('watchlists')
            .doc(watchlistId)
            .update({'isFavorite': true});

        // Set all other watchlists as not favorite
        final watchlistsRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('watchlists');

        final snapshot = await watchlistsRef.get();
        for (var doc in snapshot.docs) {
          if (doc.id != watchlistId) {
            await doc.reference.update({'isFavorite': false});
          }
        }

        _fetchWatchlists();  // Refresh the list after updating
      } catch (e) {
        print("Error marking watchlist as favorite: $e");
      }
    }
  }

  // Delete the selected watchlist
  Future<void> _deleteWatchlist(String watchlistId) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('watchlists')
            .doc(watchlistId)
            .delete();
        _fetchWatchlists(); // Refresh after deletion
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Watchlist deleted.")));
      } catch (e) {
        print("Error deleting watchlist: $e");
      }
    }
  }

  // Navigate to the watchlist details page
  void _navigateToWatchlistDetail(String watchlistId, String watchlistName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WatchlistDetailPage(
          watchlistId: watchlistId,
          watchlistName: watchlistName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Watchlists"),
      ),
      body: Column(
        children: [
          // Button to add a new watchlist
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _addWatchlist,
              child: Text("Add New Watchlist"),
            ),
          ),

          // Display the user's watchlists
          Expanded(
            child: watchlists.isEmpty
                ? Center(child: Text("No watchlists created."))
                : ListView.builder(
              itemCount: watchlists.length,
              itemBuilder: (context, index) {
                final watchlist = watchlists[index];
                final watchlistId = watchlist['id'];
                final watchlistName = watchlist['name'];
                final isFavorite = watchlist['isFavorite'];

                return ListTile(
                  title: Text(watchlistName),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.yellow : null,
                        ),
                        onPressed: () {
                          _markAsFavorite(watchlistId);  // Mark this watchlist as favorite
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showWatchlistDialog('Edit Watchlist', initialName: watchlistName)
                              .then((newName) {
                            if (newName.isNotEmpty) {
                              _firestore
                                  .collection('users')
                                  .doc(_auth.currentUser!.uid)
                                  .collection('watchlists')
                                  .doc(watchlistId)
                                  .update({'name': newName});
                              _fetchWatchlists();  // Refresh after updating
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteWatchlist(watchlistId), // Delete the watchlist
                      ),
                    ],
                  ),
                  onTap: () {
                    _navigateToWatchlistDetail(watchlistId, watchlistName);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Watchlist Detail Page to show stocks in a selected watchlist
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
                  // Add logic to view stock details if needed
                  // For example, navigate to a StockDetailPage
                },
              );
            },
          );
        },
      ),
    );
  }
}

class Stock {
  final String symbol;
  final String name;
  final double price;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
  });

  // Method to convert the Stock to a Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
    };
  }

  // Method to create a Stock from a Map (from Firestore)
  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] ?? 0.0,
    );
  }
}
