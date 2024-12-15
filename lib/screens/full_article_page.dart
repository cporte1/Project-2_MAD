// full_article_page.dart
import 'package:flutter/material.dart';

class FullArticlePage extends StatelessWidget {
  final String articleTitle;
  final String articleSource;
  final String articleContent;

  FullArticlePage({
    required this.articleTitle,
    required this.articleSource,
    required this.articleContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(articleTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                articleTitle,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Source: $articleSource',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                articleContent,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
