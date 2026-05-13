import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'api_failure.dart';

class ApiClient {
  ApiClient(this.baseUrl, {FirebaseAuth? auth, http.Client? client})
    : _auth = auth ?? FirebaseAuth.instance,
      _client = client ?? http.Client();

  final String baseUrl;
  final FirebaseAuth _auth;
  final http.Client _client;

  Future<Map<String, String>> _headers({bool json = true}) async {
    final token = await _auth.currentUser?.getIdToken();
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$normalizedBase$normalizedPath');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        for (final entry in queryParameters.entries)
          if (entry.value != null) entry.key: entry.value.toString(),
      },
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.get(
      _uri(path, queryParameters),
      headers: await _headers(),
    );
    return _decode(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.post(
      _uri(path, queryParameters),
      headers: await _headers(),
      body: data == null ? null : jsonEncode(data),
    );
    return _decode(response);
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.put(
      _uri(path, queryParameters),
      headers: await _headers(),
      body: data == null ? null : jsonEncode(data),
    );
    return _decode(response);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.patch(
      _uri(path, queryParameters),
      headers: await _headers(),
      body: data == null ? null : jsonEncode(data),
    );
    return _decode(response);
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _client.delete(
      _uri(path, queryParameters),
      headers: await _headers(),
    );
    return _decode(response);
  }

  Future<dynamic> multipart(
    String path, {
    required Map<String, String> fields,
    MultipartBytes? file,
    Map<String, dynamic>? queryParameters,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path, queryParameters));
    request.headers.addAll(await _headers(json: false));
    request.fields.addAll(fields);
    if (file != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          file.field,
          file.bytes,
          filename: file.filename,
          contentType: file.contentType,
        ),
      );
    }

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiFailure.fromResponse(
        statusCode: response.statusCode,
        body: response.body,
      );
    }
    if (response.body.isEmpty) {
      return null;
    }
    return jsonDecode(response.body);
  }
}

class MultipartBytes {
  const MultipartBytes({
    required this.field,
    required this.filename,
    required this.bytes,
    this.contentType,
  });

  final String field;
  final String filename;
  final Uint8List bytes;
  final MediaType? contentType;
}
