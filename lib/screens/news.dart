// news.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/news_service.dart';  // Service for fetching news
import 'full_article_page.dart'; // Import the FullArticlePage to navigate to

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _user;
  final NewsService _newsService = NewsService();

  List<Map<String, dynamic>> _trendingNews = [];
  bool _showMoreTrendingNews = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _fetchTrendingNews();
  }

  // Fetch trending news
  Future<void> _fetchTrendingNews() async {
    try {
      final trendingNews = await _newsService.fetchTrendingNews();
      setState(() {
        _trendingNews = trendingNews;
      });
    } catch (e) {
      print("Error fetching Trending News: $e");
    }
  }

  // Limit the number of articles displayed (5)
  List<Map<String, dynamic>> _getLimitedArticles(List<Map<String, dynamic>> articles, bool showAll) {
    return showAll ? articles : articles.take(5).toList();
  }

  // Navigate to the full article page
  void _navigateToFullArticle(String title, String source, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullArticlePage(
          articleTitle: title,
          articleSource: source,
          articleContent: content,
        ),
      ),
    );
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
              // Trending News Section
              _buildSectionTitle("Trending News"),
              _buildTrendingNewsSection(),
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

  // Trending News Section
  Widget _buildTrendingNewsSection() {
    List<Map<String, dynamic>> limitedTrendingNews = _getLimitedArticles(_trendingNews, _showMoreTrendingNews);

    return Column(
      children: [
        Column(
          children: limitedTrendingNews.map((article) {
            return ListTile(
              title: Text(article['headline']),
              subtitle: Text(article['source']),
              onTap: () {
                _navigateToFullArticle(article['headline'], article['source'], article['summary']);  // Navigate to full article
              },
            );
          }).toList(),
        ),
        if (_trendingNews.length > 5)
          TextButton(
            onPressed: () {
              setState(() {
                _showMoreTrendingNews = !_showMoreTrendingNews;
              });
            },
            child: Text(_showMoreTrendingNews ? "Show Less" : "View More..."),
          ),
      ],
    );
  }
}
