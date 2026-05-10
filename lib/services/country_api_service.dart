import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/Country.dart';
import 'api_exception.dart';

/// Service class that handles ALL HTTP communication with the RestCountries API.
/// No HTTP logic exists outside this class.
class CountryApiService {
  static const String _baseUrl = 'restcountries.com';
  static const String _basePath = '/v3.1';

  static const Duration _timeout = Duration(seconds: 10);

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Validates an [http.Response] and throws [ApiException] if status != 200.
  void _checkResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Request to ${response.request?.url} failed.',
      );
    }
  }

  /// Fetches ALL countries with only the fields needed for the list screen.
  /// GET /all?fields=name,flags,flag,region,population,cca3
  Future<List<Country>> fetchAllCountries() async {
    final uri = Uri.https(
      _baseUrl,
      '$_basePath/all',
      {'fields': 'name,flags,flag,region,population,cca3'},
    );

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

      _checkResponse(response);

      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => Country.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on ApiException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Searches countries by common name.
  /// GET /name/{name}
  Future<List<Country>> searchByName(String name) async {
    final uri = Uri.https(_baseUrl, '$_basePath/name/$name');

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

      // 404 means no results — return empty list instead of throwing
      if (response.statusCode == 404) return [];

      _checkResponse(response);

      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((e) => Country.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on ApiException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }

  /// Fetches a single country by its ISO alpha-3 code for the detail screen.
  /// GET /alpha/{code}
  Future<Country> fetchByCode(String code) async {
    final uri = Uri.https(_baseUrl, '$_basePath/alpha/$code');

    try {
      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

      _checkResponse(response);

      // /alpha returns a list with one element
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List && decoded.isNotEmpty) {
        return Country.fromJson(decoded.first as Map<String, dynamic>);
      }
      if (decoded is Map<String, dynamic>) {
        return Country.fromJson(decoded);
      }
      throw const FormatException('Unexpected JSON structure for country detail.');
    } on SocketException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on ApiException {
      rethrow;
    } on FormatException {
      rethrow;
    }
  }
}
