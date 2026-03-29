import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../errors/failures.dart';

class ApiClient {
  static final StreamController<void> onUnauthorized = StreamController<void>.broadcast();

  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // Get Firebase ID Token
  Future<String?> _getToken({bool forceRefresh = false}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken(forceRefresh);
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Could not get Firebase token: $e');
    }
    return null;
  }

  // Build Headers
  Future<Map<String, String>> _buildHeaders({bool forceRefresh = false}) async {
    final token = await _getToken(forceRefresh: forceRefresh);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // GET Request
  Future<Map<String, dynamic>> get(String url, {bool isRetry = false}) async {
    try {
      final headers = await _buildHeaders(forceRefresh: isRetry);
      if (kDebugMode) print('🌐 GET $url');
      final response = await _client.get(Uri.parse(url), headers: headers);
      
      if (response.statusCode == 401 && !isRetry) {
        if (kDebugMode) print('🔄 Token expired, refreshing GET...');
        return await get(url, isRetry: true);
      }
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure('Tidak dapat terhubung ke server');
    } on http.ClientException catch (e) {
      if (kDebugMode) print('❌ ClientException GET: $e');
      throw NetworkFailure('Koneksi terputus: ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Auth error');
    }
  }

  // POST Request
  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    bool isRetry = false,
  }) async {
    try {
      final headers = await _buildHeaders(forceRefresh: isRetry);
      if (kDebugMode) print('🌐 POST $url | body: $body');
      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      
      if (response.statusCode == 401 && !isRetry) {
        if (kDebugMode) print('🔄 Token expired, refreshing POST...');
        return await post(url, body: body, isRetry: true);
      }
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure('Tidak dapat terhubung ke server');
    } on http.ClientException catch (e) {
      if (kDebugMode) print('❌ ClientException POST: $e');
      throw NetworkFailure('Koneksi terputus: ${e.message}');
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Auth error');
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? body,
    bool isRetry = false,
  }) async {
    try {
      final headers = await _buildHeaders(forceRefresh: isRetry);
      final response = await _client.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      
      if (response.statusCode == 401 && !isRetry) {
        if (kDebugMode) print('🔄 Token expired, refreshing PUT...');
        return await put(url, body: body, isRetry: true);
      }
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure('Tidak dapat terhubung ke server');
    } on http.ClientException catch (e) {
      if (kDebugMode) print('❌ ClientException PUT: $e');
      throw NetworkFailure('Koneksi terputus: ${e.message}');
    }
  }

  // Response Handler
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (kDebugMode) {
      print('📡 ${response.statusCode} ${response.request?.url}');
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 401) {
      onUnauthorized.add(null);
      throw const AuthFailure();
    }
    String message = 'Server error (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      message = body['message'] ?? message;
    } catch (_) {}
    throw ServerFailure(message, statusCode: response.statusCode);
  }

  // Download binary file (e.g. Excel export)
  Future<List<int>> downloadFile(String url, {bool isRetry = false}) async {
    try {
      final headers = await _buildHeaders(forceRefresh: isRetry);
      // Remove Content-Type for download, accept anything
      headers.remove('Content-Type');
      headers['Accept'] = '*/*';
      if (kDebugMode) print('📥 DOWNLOAD $url');
      final response = await _client.get(Uri.parse(url), headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      if (response.statusCode == 401 && !isRetry) {
        if (kDebugMode) print('🔄 Token expired, refreshing DOWNLOAD...');
        return await downloadFile(url, isRetry: true);
      }
      if (response.statusCode == 401) {
        onUnauthorized.add(null);
        throw const AuthFailure();
      }
      throw ServerFailure('Download gagal (${response.statusCode})', statusCode: response.statusCode);
    } on SocketException {
      throw const NetworkFailure('Tidak dapat terhubung ke server');
    } on http.ClientException catch (e) {
      if (kDebugMode) print('❌ ClientException DOWNLOAD: $e');
      throw NetworkFailure('Koneksi terputus: ${e.message}');
    }
  }
}