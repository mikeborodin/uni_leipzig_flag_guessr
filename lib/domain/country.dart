class Country {
  final String commonName;
  final String officialName;
  final String flagCharacter; // The API provides a flag emoji as string: 🇩🇪
  bool isFavorite;

  Country({
    required this.commonName,
    required this.officialName,
    required this.flagCharacter,
    this.isFavorite = false, // Default to not favorite
  });

  // Factory constructor to create a Country instance from JSON data
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      commonName: json['name']?['common'] ?? 'N/A', // Safely access nested 'common' name
      officialName: json['name']?['official'] ?? 'N/A', // Safely access nested 'official' name
      flagCharacter: json['flag'] ?? '🏳️', // Provide a default flag if missing
    );
  }

  // Method to convert a Country instance to a JSON map (for local storage)
  // Note: isFavorite is managed separately in the favorites file
  Map<String, dynamic> toJson() {
    return {
      'name': {'common': commonName, 'official': officialName},
      'flag': flagCharacter,
    };
  }
}
