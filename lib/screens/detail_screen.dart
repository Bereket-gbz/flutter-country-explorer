import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/Country.dart';
import '../services/api_exception.dart';
import '../services/country_api_service.dart';

/// Detail screen — fetches full country data by ISO alpha-3 code.
class DetailScreen extends StatefulWidget {
  final String alpha3Code;
  final String countryName;
  // Optional pre-loaded country data (from list screen) used as fallback
  final Country? preloadedCountry;

  const DetailScreen({
    super.key,
    required this.alpha3Code,
    required this.countryName,
    this.preloadedCountry,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final CountryApiService _apiService = CountryApiService();
  late Future<Country> _countryFuture;

  @override
  void initState() {
    super.initState();
    _loadCountry();
  }

  void _loadCountry() {
    setState(() {
      _countryFuture = _apiService.fetchByCode(widget.alpha3Code);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4ECDC4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.countryName.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF4ECDC4),
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
      body: FutureBuilder<Country>(
        future: _countryFuture,
        builder: (context, snapshot) {
          // State 1: Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
            );
          }

          // State 2: Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        color: Color(0xFFEF4444), size: 52),
                    const SizedBox(height: 16),
                    Text(
                      _buildErrorMessage(snapshot.error!),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFFD1D5DB), fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadCountry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4ECDC4),
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // State 3: No data — fall back to preloaded if available
          if (!snapshot.hasData) {
            if (widget.preloadedCountry != null) {
              return _CountryDetail(country: widget.preloadedCountry!);
            }
            return const Center(
              child: Text('No country data available.',
                  style: TextStyle(color: Color(0xFF6B7280))),
            );
          }

          // State 4: Data
          return _CountryDetail(country: snapshot.data!);
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Detail body
// ──────────────────────────────────────────────────────────

class _CountryDetail extends StatelessWidget {
  final Country country;

  const _CountryDetail({required this.country});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flag banner
          if (country.flagPng.isNotEmpty)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  country.flagPng,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      country.flagEmoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Official name
          Text(
            country.officialName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (country.officialName != country.commonName)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                country.commonName,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 15,
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Info grid
          _InfoGrid(country: country),

          const SizedBox(height: 24),

          // Currencies
          if (country.currencies.isNotEmpty) ...[
            _SectionHeader(title: 'Currencies', icon: Icons.currency_exchange),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: country.currencies.entries
                  .map((e) => _Chip(label: '${e.key} · ${e.value}'))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Languages
          if (country.languages.isNotEmpty) ...[
            _SectionHeader(title: 'Languages', icon: Icons.translate),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: country.languages.values
                  .map((lang) => _Chip(label: lang))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Timezones
          if (country.timezones.isNotEmpty) ...[
            _SectionHeader(title: 'Timezones', icon: Icons.access_time),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: country.timezones
                  .map((tz) => _Chip(label: tz))
                  .toList(),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4ECDC4), size: 16),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF4ECDC4),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final Country country;

  const _InfoGrid({required this.country});

  @override
  Widget build(BuildContext context) {
    final items = [
      _InfoItem(
        icon: Icons.location_city,
        label: 'Capital',
        value: country.capital.isNotEmpty
            ? country.capital.join(', ')
            : 'N/A',
      ),
      _InfoItem(
        icon: Icons.people,
        label: 'Population',
        value: _formatNumber(country.population),
      ),
      _InfoItem(
        icon: Icons.public,
        label: 'Region',
        value: country.region.isNotEmpty ? country.region : 'N/A',
      ),
      _InfoItem(
        icon: Icons.map,
        label: 'Subregion',
        value: country.subregion.isNotEmpty ? country.subregion : 'N/A',
      ),
      _InfoItem(
        icon: Icons.straighten,
        label: 'Area',
        value: '${_formatNumber(country.area.toInt())} km²',
      ),
      _InfoItem(
        icon: Icons.tag,
        label: 'ISO Code',
        value: country.alpha3Code,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: items.map((item) => _InfoCard(item: item)).toList(),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000000) return '${(n / 1000000000).toStringAsFixed(2)}B';
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(2)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({required this.icon, required this.label, required this.value});
}

class _InfoCard extends StatelessWidget {
  final _InfoItem item;

  const _InfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: const Color(0xFF4ECDC4), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  item.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D3D3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4ECDC4),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
