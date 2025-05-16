import 'package:flutter/material.dart';

import 'screens/countries_list_screen.dart';
import 'theme.dart';

class CountriesApp extends StatelessWidget {
  const CountriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flag Guessr',
      theme: appTheme,
      debugShowCheckedModeBanner: false, // Hide the debug banner
      home: const CountryListScreen(), // Set the initial screen
    );
  }
}
