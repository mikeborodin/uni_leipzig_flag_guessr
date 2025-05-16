import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../domain/country.dart';

class CountriesRepository {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get countriesCacheFile async {
    final path = await _localPath;
    return File('$path/countries_cache.json');
  }

  // Helper to get the file for storing favorites
  Future<File> get favoritesFile async {
    final path = await _localPath;
    return File('$path/favorites.json');
  }

  Future<http.Response> loadFromApi() async {
    final response = await http.get(
      Uri.parse('https://restcountries.com/v3.1/all?fields=name,flag'),
    );
    return response;
  }

  Future<Map<String, bool>> readFavorites() async {
    final file = await favoritesFile;
    final contents = await file.readAsString();
    if (contents.isNotEmpty) {
      final Map<String, dynamic> jsonData = json.decode(contents);
      return jsonData.map((key, value) => MapEntry(key, value as bool));
    } else {
      return {}; // Initialize if file is empty
    }
  }

  Future<List<Country>> storeInCache(http.Response response) async {
    final List<dynamic> jsonData = json.decode(response.body);
    final List<Country> fetchedCountries =
       
        jsonData.map((item) => Country.fromJson(item)).toList();

    // Save to cache file
    final file = await countriesCacheFile;
    
    await file.writeAsString(
      json.encode(fetchedCountries.map((c) => c.toJson()).toList()),

    );
    return fetchedCountries;
  }

  Future<List<Country>> readFromFile() async {
    final countriesFile = await countriesCacheFile;
    final contents = await countriesFile.readAsString();
    final List<dynamic> jsonData = json.decode(contents);
    final result = jsonData.map((item) => Country.fromJson(item)).toList();
    return result;
  }
}
