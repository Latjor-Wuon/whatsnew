import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "News App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NewsHomePage(),
    );
  }
}

class NewsHomePage extends StatefulWidget {
  const NewsHomePage({super.key});

  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  String apiKey = "6ac1195a3a2d436d906f9cded8cefa69";
  String selectedTopic = "Apple";
  List<dynamic> articles = [];

  Map<String, String> endpoints = {
    "Apple": "https://newsapi.org/v2/everything?q=apple&from=2024-11-21&to=2024-11-21&sortBy=popularity&apiKey=6ac1195a3a2d436d906f9cded8cefa69",
    "Tesla": "https://newsapi.org/v2/everything?q=tesla&from=2024-10-22&sortBy=publishedAt&apiKey=6ac1195a3a2d436d906f9cded8cefa69",
    "Business": "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=6ac1195a3a2d436d906f9cded8cefa69",
    "TechCrunch": "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=6ac1195a3a2d436d906f9cded8cefa69",
    "Wall Street Journal": "https://newsapi.org/v2/everything?domains=wsj.com&apiKey=6ac1195a3a2d436d906f9cded8cefa69",
  };

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    final url = endpoints[selectedTopic]!;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        articles = json.decode(response.body)['articles'];
      });
    } else {
      print("Failed to load articles");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("News Topics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedTopic,
              items: endpoints.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTopic = value!;
                  fetchArticles();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: article['urlToImage'] != null
                        ? Image.network(
                            article['urlToImage'],
                            width: 50,
                            fit: BoxFit.cover,
                          )
                        : null,
                    title: Text(
                      article['title'] ?? "No Title",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      article['description'] ?? "No Description",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ArticleScreen(article: article),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Article Details"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              article['urlToImage'] != null
                  ? Image.network(article['urlToImage'])
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
              Text(
                article['title'] ?? "No Title",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                article['content'] ?? "No Content Available",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("This feature will open the full article."),
                    ),
                  );
                  // Use url_launcher to open link here
                },
                child: const Text("Read Full Article"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About"),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Welcome to the News App! Explore the latest articles from various "
            "topics, including Apple, Tesla, Business, and more. Tap on an article "
            "to view its details.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
