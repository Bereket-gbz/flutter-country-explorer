/// Typed Dart model for a country returned by the RestCountries API.
class Country {
  final String commonName;
  final String officialName;
  final String flagEmoji;
  final String flagPng;
  final String region;
  final String subregion;
  final List<String> capital;
  final int population;
  final Map<String, String> currencies; // code -> name
  final Map<String, String> languages;  // code -> name
  final double area;
  final List<String> timezones;
  final String alpha3Code;

  const Country({
    required this.commonName,
    required this.officialName,
    required this.flagEmoji,
    required this.flagPng,
    required this.region,
    required this.subregion,
    required this.capital,
    required this.population,
    required this.currencies,
    required this.languages,
    required this.area,
    required this.timezones,
    required this.alpha3Code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // Parse name
    final nameObj = json['name'] as Map<String, dynamic>? ?? {};
    final commonName = (nameObj['common'] as String?) ?? 'Unknown';
    final officialName = (nameObj['official'] as String?) ?? 'Unknown';

    // Parse flags
    final flagsObj = json['flags'] as Map<String, dynamic>? ?? {};
    final flagEmoji = (json['flag'] as String?) ?? '';
    final flagPng = (flagsObj['png'] as String?) ?? '';

    // Parse capital (array)
    final capitalRaw = json['capital'];
    final capital = capitalRaw is List
        ? capitalRaw.map((e) => e as String).toList()
        : <String>[];

    // Parse currencies: { "USD": { "name": "US dollar", "symbol": "$" } }
    final currenciesRaw = json['currencies'] as Map<String, dynamic>? ?? {};
    final currencies = currenciesRaw.map((code, value) {
      final currencyMap = value as Map<String, dynamic>;
      return MapEntry(code, (currencyMap['name'] as String?) ?? code);
    });

    // Parse languages: { "eng": "English" }
    final languagesRaw = json['languages'] as Map<String, dynamic>? ?? {};
    final languages = languagesRaw.map(
      (code, name) => MapEntry(code, (name as String?) ?? code),
    );

    // Parse timezones
    final timezonesRaw = json['timezones'];
    final timezones = timezonesRaw is List
        ? timezonesRaw.map((e) => e as String).toList()
        : <String>[];

    // Parse alpha3Code (cca3)
    final alpha3Code = (json['cca3'] as String?) ?? '';

    return Country(
      commonName: commonName,
      officialName: officialName,
      flagEmoji: flagEmoji,
      flagPng: flagPng,
      region: (json['region'] as String?) ?? '',
      subregion: (json['subregion'] as String?) ?? '',
      capital: capital,
      population: (json['population'] as int?) ?? 0,
      currencies: currencies,
      languages: languages,
      area: ((json['area'] as num?) ?? 0).toDouble(),
      timezones: timezones,
      alpha3Code: alpha3Code,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': {'common': commonName, 'official': officialName},
        'flag': flagEmoji,
        'flags': {'png': flagPng},
        'region': region,
        'subregion': subregion,
        'capital': capital,
        'population': population,
        'currencies': currencies.map(
          (code, name) => MapEntry(code, {'name': name}),
        ),
        'languages': languages,
        'area': area,
        'timezones': timezones,
        'cca3': alpha3Code,
      };

  Country copyWith({
    String? commonName,
    String? officialName,
    String? flagEmoji,
    String? flagPng,
    String? region,
    String? subregion,
    List<String>? capital,
    int? population,
    Map<String, String>? currencies,
    Map<String, String>? languages,
    double? area,
    List<String>? timezones,
    String? alpha3Code,
  }) {
    return Country(
      commonName: commonName ?? this.commonName,
      officialName: officialName ?? this.officialName,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      flagPng: flagPng ?? this.flagPng,
      region: region ?? this.region,
      subregion: subregion ?? this.subregion,
      capital: capital ?? this.capital,
      population: population ?? this.population,
      currencies: currencies ?? this.currencies,
      languages: languages ?? this.languages,
      area: area ?? this.area,
      timezones: timezones ?? this.timezones,
      alpha3Code: alpha3Code ?? this.alpha3Code,
    );
  }
}
