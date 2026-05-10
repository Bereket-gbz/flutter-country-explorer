/// Custom exception for non-200 HTTP responses from the REST Countries API.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';

  /// User-friendly message suitable for display in the UI.
  String get userMessage {
    switch (statusCode) {
      case 400:
        return 'Bad request (400). Please check your input.';
      case 404:
        return 'Not found (404). The requested resource does not exist.';
      case 429:
        return 'Too many requests (429). Please wait and try again.';
      case 500:
        return 'Server error (500). The server is temporarily unavailable.';
      default:
        return 'Server returned status $statusCode. Please try again.';
    }
  }
}
