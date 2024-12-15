import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FAQ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(
                'What is this app?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('This app helps you track stock prices and manage a watchlist.'),
            ),
            ListTile(
              title: Text(
                'How do I add a stock to my watchlist?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Go to the Manage Watchlist page and click the add button next to a stock.'),
            ),
            ListTile(
              title: Text(
                'How do I edit my account?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Go to the Account Settings page and click "Edit Account" to change your display name.'),
            ),
            ListTile(
              title: Text(
                'How do I logout?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Click the "Log Out" button in your Account Settings.'),
            ),
          ],
        ),
      ),
    );
  }
}
