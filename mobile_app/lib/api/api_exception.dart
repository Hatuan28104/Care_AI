class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  String debug() {
    if (statusCode == null) return "ApiException: $message";
    return "ApiException($statusCode): $message";
  }
}
