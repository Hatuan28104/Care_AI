class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => "Đã xảy ra lỗi. Vui lòng thử lại.";

  String debug() {
    if (statusCode == null) return "ApiException: $message";
    return "ApiException($statusCode): $message";
  }
}
