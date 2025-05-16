
import 'package:flutter/material.dart';

import '../../domain/country.dart';


class CountryDetailScreen extends StatelessWidget {
  final Country country;

  const CountryDetailScreen({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(country.commonName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                country.flagCharacter,
                style: const TextStyle(fontSize: 120), // Large flag emoji
              ),
              const SizedBox(height: 30),
              Text(
                country.commonName,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Official Name: ${country.officialName}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(
                  country.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: country.isFavorite ? Colors.redAccent : null,
                ),
                label: Text(country.isFavorite ? "Favorited" : "Not in Favorites"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: country.isFavorite ? Colors.pink[50] : Colors.grey[200],
                  foregroundColor: country.isFavorite ? Colors.pinkAccent : Colors.black87,
                ),
                onPressed: () {
                  // Note: This button in detail screen doesn't update the list screen's state directly.
                  // For a fully synced experience here without advanced state management,
                  // you might pass a callback or pop with a result.
                  // For simplicity as per requirements, it only reflects the state passed to it.
                  // To make it interactive and update global state, _toggleFavorite from list screen would need to be accessible.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${country.commonName} is ${country.isFavorite ? "a favorite" : "not a favorite"}. Manage favorites on the main list.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
