import 'dart:convert';

class ApiFailure implements Exception {
  const ApiFailure(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  factory ApiFailure.fromResponse({
    required int statusCode,
    required String body,
  }) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final nested = decoded['error'];
        return ApiFailure(
          decoded['detail']?.toString() ??
              (nested is Map ? nested['message']?.toString() : null) ??
              'Request failed',
          code: nested is Map ? nested['code']?.toString() : null,
          statusCode: statusCode,
        );
      }
    } catch (_) {
      // Fall through to a generic message below.
    }

    return ApiFailure('Request failed', statusCode: statusCode);
  }

  @override
  String toString() => message;
}
