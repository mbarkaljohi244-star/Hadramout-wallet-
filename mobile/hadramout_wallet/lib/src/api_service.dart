import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

class ApiService {
  ApiService({
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'hadramout_access_token';
  static const _userIdKey = 'hadramout_user_id';
  static const _walletIdKey = 'hadramout_wallet_id';

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api',
  );

  final http.Client _client;
  final FlutterSecureStorage _storage;
  UserSession? _session;

  UserSession? get session => _session;

  Future<UserSession?> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    final userId = await _storage.read(key: _userIdKey);
    final walletId = await _storage.read(key: _walletIdKey);

    if (token == null || userId == null || walletId == null) {
      return null;
    }

    _session = UserSession(
      accessToken: token,
      userId: userId,
      walletId: walletId,
    );
    return _session;
  }

  Future<UserSession> login({
    required String walletId,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'walletId': walletId.trim().toUpperCase(),
        'password': password,
      }),
    );
    final session = UserSession.fromJson(_decodeOrThrow(response));
    await _saveSession(session);
    return session;
  }

  Future<UserSession> register({
    String? name,
    String? email,
    required String password,
    required String pin,
  }) async {
    final response = await _client.post(
      _uri('/users/register'),
      headers: _jsonHeaders,
      body: jsonEncode({
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        'password': password,
        'pin': pin,
      }),
    );
    final session = UserSession.fromJson(_decodeOrThrow(response));
    await _saveSession(session);
    return session;
  }

  Future<TransferResult> transfer({
    required String receiverWalletId,
    required double amount,
    required String currency,
    String? pin,
  }) async {
    final currentSession = _session;
    final response = await _client.post(
      _uri('/transfer'),
      headers: {
        ..._jsonHeaders,
        if (currentSession != null)
          'Authorization': 'Bearer ${currentSession.accessToken}',
      },
      body: jsonEncode({
        'senderWalletId': currentSession?.walletId ?? '',
        'receiverWalletId': receiverWalletId.trim().toUpperCase(),
        'amount': amount,
        'currency': currency,
        if (pin != null && pin.isNotEmpty) 'pin': pin,
      }),
    );
    return TransferResult.fromJson(_decodeOrThrow(response));
  }

  Future<void> logout() async {
    _session = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _walletIdKey);
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<void> _saveSession(UserSession session) async {
    _session = session;
    await _storage.write(key: _tokenKey, value: session.accessToken);
    await _storage.write(key: _userIdKey, value: session.userId);
    await _storage.write(key: _walletIdKey, value: session.walletId);
  }

  Map<String, dynamic> _decodeOrThrow(http.Response response) {
    Map<String, dynamic> payload = <String, dynamic>{};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        payload = decoded;
      }
    } catch (_) {
      payload = <String, dynamic>{};
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        payload['error'] as String? ?? 'تعذر الاتصال بالخادم',
        statusCode: response.statusCode,
      );
    }
    return payload;
  }

  Map<String, String> get _jsonHeaders => const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
}
