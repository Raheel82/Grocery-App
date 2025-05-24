import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({Key? key}) : super(key: key);

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<dynamic> recommendations = [];
  List<dynamic> customRecommendations = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      fetchRecommendations();
      fetchCustomRecommendations();
    }
  }

  Future<void> fetchRecommendations() async {
    if (user == null) return;
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/recommendations?userId=${user!.uid}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          recommendations = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load recommendations: ${response.body}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> fetchCustomRecommendations() async {
    if (user == null) return;
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/custom-recommendations?userId=${user!.uid}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          customRecommendations = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load custom recommendations: ${response.body}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF203a43),
        title: const Text('Recommendations', style: TextStyle(color: Colors.white)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Collaborative Recommendations",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            recommendations.isEmpty
                ? const Center(
                child: Text('No collaborative recommendations yet',
                    style: TextStyle(color: Colors.white70)))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final item = recommendations[index];
                return ListTile(
                  tileColor: const Color(0xFF203a43),
                  title: Text(item['name'] ?? 'Unnamed',
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '₹${item['price'] ?? 0} | ${item['category'] ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Category-Based Recommendations",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            customRecommendations.isEmpty
                ? const Center(
                child: Text('No category-based recommendations yet',
                    style: TextStyle(color: Colors.white70)))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: customRecommendations.length,
              itemBuilder: (context, index) {
                final item = customRecommendations[index];
                return ListTile(
                  tileColor: const Color(0xFF203a43),
                  title: Text(item['name'] ?? 'Unnamed',
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '₹${item['price'] ?? 0} | ${item['category'] ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
