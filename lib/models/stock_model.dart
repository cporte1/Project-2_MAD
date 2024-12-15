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
    // If price is null, default to 0.0
    return Stock(
      symbol: map['symbol'] ?? '',
      name: map['name'] ?? '',
      price: map['price'] != null ? map['price'].toDouble() : 0.0,  // Ensure price is treated as double
    );
  }
}
