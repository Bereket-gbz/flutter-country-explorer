import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/Country.dart';
import '../services/api_exception.dart';
import '../services/country_api_service.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CountryApiService _apiService = CountryApiService();
  late Future<List<Country>> _countriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  void _loadCountries() {
    setState(() {
      _countriesFuture = _apiService.fetchAllCountries();
    });
  }

  String _buildErrorMessage(Object error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is ApiException) {
      return error.userMessage;
    } else if (error is FormatException) {
      return 'Unexpected data format received.';
    }
    return 'An unexpected error occurred: ${error.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WORLD EXPLORER',
              style: TextStyle(
                color: Color(0xFF4ECDC4),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
            Text(
              'Browse every nation on Earth',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF4ECDC4)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            tooltip: 'Search countries',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Country>>(
        future: _countriesFuture,
        builder: (context, snapshot) {
          // State 1: Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingWidget();
          }

          // State 2: Error
          if (snapshot.hasError) {
            return _ErrorWidget(
              message: _buildErrorMessage(snapshot.error!),
              onRetry: _loadCountries,
            );
          }

          // State 3: No data
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const _EmptyWidget();
          }

          // State 4: Data
          final countries = snapshot.data!;
          // Sort alphabetically by common name
          countries.sort((a, b) => a.commonName.compareTo(b.commonName));

          return _CountryList(countries: countries);
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Sub-widgets
// ──────────────────────────────────────────────────────────

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF4ECDC4)),
          SizedBox(height: 20),
          Text(
            'Loading countries...',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Color(0xFFEF4444), size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No countries found.',
        style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
      ),
    );
  }
}

class _CountryList extends StatelessWidget {
  final List<Country> countries;

  const _CountryList({required this.countries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        return _CountryTile(country: country);
      },
    );
  }
}

class _CountryTile extends StatelessWidget {
  final Country country;

  const _CountryTile({required this.country});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(
              alpha3Code: country.alpha3Code,
              countryName: country.commonName,
              preloadedCountry: country,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: Row(
          children: [
            // Flag image or emoji fallback
            _FlagWidget(flagPng: country.flagPng, flagEmoji: country.flagEmoji),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.commonName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.public, color: Color(0xFF6B7280), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        country.region.isNotEmpty ? country.region : 'Unknown',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              _formatPopulation(country.population),
              style: const TextStyle(
                color: Color(0xFF4ECDC4),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF374151), size: 20),
          ],
        ),
      ),
    );
  }

  String _formatPopulation(int pop) {
    if (pop >= 1000000000) return '${(pop / 1000000000).toStringAsFixed(1)}B';
    if (pop >= 1000000) return '${(pop / 1000000).toStringAsFixed(1)}M';
    if (pop >= 1000) return '${(pop / 1000).toStringAsFixed(0)}K';
    return pop.toString();
  }
}

class _FlagWidget extends StatelessWidget {
  final String flagPng;
  final String flagEmoji;

  const _FlagWidget({required this.flagPng, required this.flagEmoji});

  @override
  Widget build(BuildContext context) {
    if (flagPng.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          flagPng,
          width: 48,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _emojiFallback(),
        ),
      );
    }
    return _emojiFallback();
  }

  Widget _emojiFallback() {
    return Container(
      width: 48,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(flagEmoji, style: const TextStyle(fontSize: 22)),
    );
  }
}
