// lib/api/api_error.dart

class ApiError implements Exception {
  final int statusCode;
  final String backendMessage;
  final String uiMessage;

  const ApiError({
    required this.statusCode,
    required this.backendMessage,
    required this.uiMessage,
  });

  @override
  String toString() =>
      'ApiError(statusCode: $statusCode, backendMessage: $backendMessage, uiMessage: $uiMessage)';
}