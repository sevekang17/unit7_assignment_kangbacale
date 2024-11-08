import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, List<dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = fetchMealsByLetter();
  }

  Future<Map<String, List<dynamic>>> fetchMealsByLetter() async {
    Map<String, List<dynamic>> mealsByLetter = {};
    List<String> letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

    for (String letter in letters) {
      final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?f=$letter'));
      if (response.statusCode == 200) {
        var meals = json.decode(response.body)['meals'];
        if (meals != null && meals.isNotEmpty) {
          mealsByLetter[letter] = meals;
        }
      } else {
        throw Exception('Failed to load meals for letter $letter');
      }
    }
    return mealsByLetter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Ideas with Recipes"),
      ),
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.keys.length,
              itemBuilder: (context, index) {
                String letter = snapshot.data!.keys.elementAt(index);
                List<dynamic> meals = snapshot.data![letter]!;

                return ExpansionTile(
                  title: Text(letter, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: meals.length,
                      itemBuilder: (context, mealIndex) {
                        final meal = meals[mealIndex];

                        return ExpansionTile(
                          title: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  meal['strMealThumb'] ?? 'https://via.placeholder.com/150',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  meal['strMeal'] ?? 'No name available',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Category: ${meal['strCategory'] ?? 'No category available'}'),
                                  const SizedBox(height: 8),
                                  Text('National Origin: ${meal['strArea'] ?? 'No area available'}'),
                                  const SizedBox(height: 8),
                                  Text('Instructions: ${meal['strInstructions'] ?? 'No instructions available'}'),
                                  const SizedBox(height: 8),
                                  Text('Tags: ${meal['strTags'] ?? 'No tags available'}'),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
          return const Center(child: Text("No data available"));
        },
      ),
    );
  }
}
