import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase
    final User? user = FirebaseAuth.instance.currentUser;

    // Extract the email without the domain part
    final String email = user?.email ?? 'No email available';
    final String displayName = email.split('@')[0]; // Get part before @ symbol

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
      ),
      body: Center( // Center the entire content horizontally
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align content at the top of the screen
            crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
            children: <Widget>[
              // Circular user image
              CircleAvatar(
                radius: 50, // Size of the avatar
                backgroundColor: Colors.blueGrey,
                backgroundImage: NetworkImage(user?.photoURL ?? ''),
                child: user?.photoURL == null
                    ? Icon(Icons.person, size: 50, color: Colors.white) // Placeholder if no photo
                    : null,
              ),
              SizedBox(height: 20), // Space between avatar and the welcome message

              // Display the welcome message with the user's email (without domain)
              Text(
                'Welcome Back, $displayName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20), // Space between the message and the buttons

              // Manage Watchlist Button
              _buildActionButton(
                context,
                'Manage Watchlist',
                    () {
                  // Navigate to the Manage Watchlist page
                  Navigator.pushNamed(context, '/manageWatchlist');
                },
              ),
              SizedBox(height: 10), // Space between buttons

              // Edit Account Button
              _buildActionButton(
                context,
                'Edit Account',
                    () {
                  // Navigate to the Edit Account page
                  Navigator.pushNamed(context, '/editAccount');
                },
              ),
              SizedBox(height: 10), // Space between buttons

              // FAQ Button
              _buildActionButton(
                context,
                'FAQ',
                    () {
                  // Navigate to the FAQ page
                  Navigator.pushNamed(context, '/faq');
                },
              ),
              SizedBox(height: 20), // Space between the buttons and the log out button

              // Log Out Button
              ElevatedButton(
                onPressed: () {
                  // Handle the action, like logging out
                  FirebaseAuth.instance.signOut();
                  // Navigate to login page after logout
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable widget for the rectangular buttons
  Widget _buildActionButton(BuildContext context, String label, Function() onPressed) {
    return SizedBox(
      width: double.infinity, // Make the button span the entire width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Make the button rectangular
          padding: EdgeInsets.symmetric(vertical: 15), // Add vertical padding
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontSize: 18)), // Button text style
      ),
    );
  }
}
