import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/Country.dart';
import '../services/api_exception.dart';
import '../services/country_api_service.dart';
import 'detail_screen.dart';

/// Search screen with 400ms debouncing (Bonus Task: +5 marks).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CountryApiService _apiService = CountryApiService();
  final TextEditingController _controller = TextEditingController();

  Timer? _debounceTimer;
  bool _isLoading = false;
  bool _isDebouncing = false;
  List<Country> _results = [];
  String? _errorMessage;
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _results = [];
          _hasSearched = false;
          _errorMessage = null;
          _isDebouncing = false;
        });
      }
      return;
    }

    // Show debouncing indicator immediately
    if (mounted) {
      setState(() {
        _isDebouncing = true;
        _errorMessage = null;
      });
    }

    // 400ms debounce delay (Bonus requirement)
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isDebouncing = false;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final results = await _apiService.searchByName(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        _isLoading = false;
      });
    } on SocketException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No internet connection. Please check your network.';
        _isLoading = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Request timed out. Please try again.';
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.userMessage;
        _isLoading = false;
      });
    } on FormatException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unexpected data format received.';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  void _retry() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) _performSearch(query);
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
        title: const Text(
          'SEARCH',
          style: TextStyle(
            color: Color(0xFF4ECDC4),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a country name...',
                hintStyle: const TextStyle(color: Color(0xFF4B5563)),
                filled: true,
                fillColor: const Color(0xFF111827),
                prefixIcon: (_isDebouncing || _isLoading)
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF4ECDC4),
                          ),
                        ),
                      )
                    : const Icon(Icons.search, color: Color(0xFF4ECDC4)),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF6B7280)),
                        onPressed: () {
                          _controller.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 1.5),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // Debouncing hint
          if (_isDebouncing)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Searching in 400ms...',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
            ),

          // Results area
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Color(0xFFEF4444), size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _retry,
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

    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.travel_explore, color: Color(0xFF1F2937), size: 72),
            SizedBox(height: 16),
            Text(
              'Type a country name to search',
              style: TextStyle(color: Color(0xFF4B5563), fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, color: Color(0xFF374151), size: 56),
            const SizedBox(height: 16),
            Text(
              'No results for "${_controller.text}"',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final country = _results[index];
        return _SearchResultTile(country: country);
      },
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Country country;

  const _SearchResultTile({required this.country});

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
            if (country.flagPng.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  country.flagPng,
                  width: 48,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Text(
                    country.flagEmoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              )
            else
              Text(country.flagEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.commonName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    country.region,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF374151), size: 20),
          ],
        ),
      ),
    );
  }
}
