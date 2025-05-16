# FlagGuessr 🌍

Project structure:


```
lib
├── data
│   └── countries_repository.dart
├── domain
│   └── country.dart
├── main.dart
└── ui
    ├── app.dart
    ├── screens
    │   ├── countries_list_screen.dart
    │   └── country_detail_screen.dart
    └── theme.dart
```

## Features
* Loading data from the Countries API
* Caching locally (using simple JSON file)
* Filtering / Searching for a country
* Marking a country as a Favorite
* Opening the country shows the flag (as emoji).


## Getting started
* Make sure you have `git` and `flutter` tools installed
* `git clone https://github.com/mikeborodin/uni_leipzig_flag_guessr`
* `cd uni_leipzig_flag_guessr`
* `flutter pub get`
* `flutter run`
