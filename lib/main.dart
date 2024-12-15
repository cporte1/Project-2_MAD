import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_tracking_app/screens/login.dart';
import 'package:stock_tracking_app/screens/register.dart';
import 'screens/home.dart';  // Home Page
import 'screens/news.dart';  // News Page
import 'screens/account.dart';  // Account Page
import 'screens/manage_watchlist.dart';  // Manage Watchlist Page
import 'screens/edit_account.dart';  // Edit Account Page
import 'screens/faq.dart';  // FAQ Page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => AuthWrapper(), // Check auth status before showing the right screen
        '/home': (context) => HomePage(),
        '/news': (context) => NewsPage(),
        '/account': (context) => AccountPage(),
        '/manageWatchlist': (context) => ManageWatchlistPage(),
        '/editAccount': (context) => EditAccountPage(),
        '/faq': (context) => FaqPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listen to auth state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading while Firebase is checking auth state
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // If user is logged in, navigate to home
          return MainPageWithTabs();
        } else {
          // If user is not logged in, navigate to login page
          return LoginPage();
        }
      },
    );
  }
}

class MainPageWithTabs extends StatefulWidget {
  @override
  _MainPageWithTabsState createState() => _MainPageWithTabsState();
}

class _MainPageWithTabsState extends State<MainPageWithTabs> {
  int _currentIndex = 0;  // Track the current tab index

  final List<Widget> _pages = [
    HomePage(),    // Home (Stock Tracker)
    NewsPage(),    // News
    AccountPage(), // Account
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;  // Update the current index when a tab is tapped
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,  // Prevent the default back button on the app bar
        title: null,  // Remove the AppBar title
      ),
      body: _pages[_currentIndex],  // Display the corresponding page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,  // Highlight the active tab
        onTap: _onTabTapped,  // Handle tab tap
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
