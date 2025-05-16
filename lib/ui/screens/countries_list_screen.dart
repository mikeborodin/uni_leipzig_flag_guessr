import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../data/countries_repository.dart';
import '../../domain/country.dart';
import 'country_detail_screen.dart';

// Using Flutter's Stateful Widget approach
class CountryListScreen extends StatefulWidget {
  const CountryListScreen({super.key});

  @override
  State<CountryListScreen> createState() => _CountryListScreenState();
}

class _CountryListScreenState extends State<CountryListScreen> {
  // Stores all countries fetched or cached
  List<Country> _allCountries = [];

  // Stores countries after filtering and sortingu
  List<Country> _filteredCountries = [];

  // Stores favorite status: { "CountryName": true/false }
  Map<String, bool> _favorites = {};

  // Current search term entered by the user
  String _searchTerm = '';

  // Indicates if data is being loaded
  bool _isLoading = true;

  // Message shown during loading
  String _loadingMessage = 'Fetching countries...';

  // Stores error messages, if any
  String _error = '';

  // For sorting by name (true for A-Z, false for Z-A)
  bool _sortAscending = true;

  // Responsible for loading the data
  final repo = CountriesRepository();

  @override
  void initState() {
    super.initState();
    _initializeData(); // Load favorites and then fetch countries
  }

  Future<void> _initializeData() async {
    await _loadFavorites();
    await _fetchOrLoadCountries();
  }

  Future<void> _fetchOrLoadCountries() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Checking local cache...';
      _error = '';
    });

    try {
      final countriesFile = await repo.countriesCacheFile;
      if (await countriesFile.exists()) {
        _allCountries = await repo.readCountriesFromCache();

        if (_allCountries.isNotEmpty) {
          _applyFavoritesFilterAndSort();
          setState(() {
            _isLoading = false;
            _loadingMessage = 'Loaded from cache. Updating in background...';
          });
          // Attempt to update from API in the background
          _fetchFromApiAndSave(isBackgroundUpdate: true);
          return; // Exit if loaded from cache
        }
      }

      // If cache doesn't exist or is empty, fetch from API
      setState(() {
        _loadingMessage = 'Spinning the globe ...';
      });

      await _fetchFromApiAndSave();
    } catch (e) {
      setState(() {
        _error = "Failed to load countries: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFromApiAndSave({bool isBackgroundUpdate = false}) async {
    try {
      http.Response response = await repo.loadCountriesFromApi();

      if (response.statusCode == 200) {
        _allCountries = await repo.storeCountriesInCache(response);

        _applyFavoritesFilterAndSort();

        if (!isBackgroundUpdate) {
          setState(() => _isLoading = false);
        } else {
          setState(() => _loadingMessage = 'Data updated.'); // Or just silently update
        }
      } else {
        if (!isBackgroundUpdate) {
          setState(() {
            _error = "API Error: ${response.statusCode}. Try loading from cache.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!isBackgroundUpdate) {
        setState(() {
          _error = "Network Error: ${e.toString()}. Try loading from cache.";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final file = await repo.favoritesFile;
      if (await file.exists()) {
        _favorites = await repo.readFavorites();
      } else {
        _favorites = {}; // Initialize if file doesn't exist
      }
    } catch (e) {
      _favorites = {}; // Reset on error
      if (mounted) {
        setState(() => _error += "\nError loading favorites: $e");
      }
    }
  }

  Future<void> _saveFavorites() async {
    try {
      await repo.writeFavorites(_favorites);
    } catch (e) {
      if (mounted) {
        setState(() => _error += "\nError saving favorites: $e");
      }
    }
  }

  void _toggleFavorite(Country country) {
    setState(() {
      // Update the favorites map
      _favorites[country.commonName] = !(_favorites[country.commonName] ?? false);
      _saveFavorites(); // Persist changes to local file
      _applyFavoritesFilterAndSort(); // Re-apply to update the UI list
    });
  }

  void _onSearchChanged(String query) {
    _searchTerm = query.toLowerCase();
    _applyFavoritesFilterAndSort();
  }

  void _toggleSortOrder() {
    setState(() {
      _sortAscending = !_sortAscending;
      _applyFavoritesFilterAndSort();
    });
  }

  void _applyFavoritesFilterAndSort() {
    // Apply favorite status from the _favorites map to each country in _allCountries
    List<Country> processedCountries =
        _allCountries.map((country) {
          return Country(
            commonName: country.commonName,
            officialName: country.officialName,
            flagCharacter: country.flagCharacter,
            isFavorite: _favorites[country.commonName] ?? false,
          );
        }).toList();

    // Filter by search term
    List<Country> tempFiltered = processedCountries;
    if (_searchTerm.isNotEmpty) {
      tempFiltered =
          processedCountries.where((country) {
            return country.commonName.toLowerCase().contains(_searchTerm);
          }).toList();
    }

    // Sort the filtered list
    tempFiltered.sort((a, b) {
      return _sortAscending
          ? a.commonName.compareTo(b.commonName)
          : b.commonName.compareTo(a.commonName);
    });

    // Update the state with the final list
    if (mounted) {
      // Check if the widget is still in the tree
      setState(() {
        _filteredCountries = tempFiltered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flag Guessr'),
        actions: [
          IconButton(
            icon: Icon(
              _sortAscending ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              semanticLabel: _sortAscending ? "Sort Z to A" : "Sort A to Z",
            ),
            tooltip: 'Sort by Name (${_sortAscending ? "A-Z" : "Z-A"})',
            onPressed: _toggleSortOrder,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search by country name...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (_isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_loadingMessage),
                  ],
                ),
              ),
            )
          else if (_error.isNotEmpty && _filteredCountries.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else if (_filteredCountries.isEmpty && _searchTerm.isNotEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No countries found for "$_searchTerm".',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          else if (_allCountries.isEmpty && !_isLoading)
            const Expanded(
              child: Center(
                child: Text(
                  'No countries available. Please check your connection or try again.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Manually trigger a fetch from API when user pulls to refresh
                  setState(() {
                    _isLoading = true;
                    _loadingMessage = 'Refreshing data from API...';
                  });
                  await _fetchFromApiAndSave();
                  setState(() {
                    _isLoading = false;
                  });
                },
                child: ListView.builder(
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    return Card(
                      child: ListTile(
                        leading: Text(
                          '❔',
                          style: const TextStyle(fontSize: 30), // Flag emoji size
                        ),
                        title: Text(
                          country.commonName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          country.officialName,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            country.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: country.isFavorite ? Colors.redAccent : Colors.grey,
                            semanticLabel:
                                country.isFavorite ? "Remove from favorites" : "Add to favorites",
                          ),
                          onPressed: () => _toggleFavorite(country),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CountryDetailScreen(country: country),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          // Display a small error message at the bottom if there's a non-critical error
          // but data is still being shown (e.g., background update failed but cache was used)
          if (_error.isNotEmpty && _filteredCountries.isNotEmpty && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Note: ${_error.split('\n').firstWhere((e) => e.isNotEmpty, orElse: () => '')}", // Show first line of error
                style: TextStyle(color: Colors.orange[700], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
