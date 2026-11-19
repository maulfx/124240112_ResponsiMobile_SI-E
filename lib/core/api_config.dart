import 'package:flutter/foundation.dart';
import 'api_adapter.dart';
import 'api_gate.dart';

/// Definisi konfigurasi satu endpoint API (opsional — hanya jika butuh method POST/header/mapping khusus).
class EndpointConfig {
  final String path;
  final HttpMethod method;
  final Map<String, String> headers;
  final Map<String, dynamic> queryParameters;
  final Object? body;

  /// Lokasi List di JSON (`''` = deteksi otomatis, termasuk root Array & list dalam list).
  final String listPath;

  /// Lokasi Object detail di JSON (`''` = deteksi otomatis).
  final String detailPath;

  /// Mapping manual (`{}` = deteksi otomatis semua field tanpa perlu remap).
  final Map<String, FieldMapping> fieldMapping;

  const EndpointConfig({
    required this.path,
    this.method = HttpMethod.get,
    this.headers = const {},
    this.queryParameters = const {},
    this.body,
    this.listPath = '',
    this.detailPath = '',
    this.fieldMapping = const {},
  });
}


class ApiConfig {
  // ╔══════════════════════════════════════════════════════════════════════╗
  // ║  1. URL DAFTAR / LIST (yang tampil di ListPage)                      ║
  // ║     Kalau besok dapat 2 atau 3 API, cukup buka komentar (//) di bawah║
  // ╚══════════════════════════════════════════════════════════════════════╝
  static const Map<String, String> urls = {
    'news': 'https://dummyjson.com/recipes',
  };

  static const Map<String, String> detailUrls = {
  
  };

  // ── OPSIONAL (Biarkan default jika tidak dibutuhkan) ────────────────────

  /// Isi token jika API butuh `Authorization: Bearer <token>`.
  static const String? authToken = null;

  /// Header global tambahan jika diperlukan API baru.
  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
  };

  /// Override lokasi List hanya jika auto-detect salah memilih list.
  static const Map<String, String> customListPaths = {};

  /// Override mapping hanya untuk 1-2 field tertentu jika hasil otomatis kurang pas.
  /// Field lain yang tidak disebut di sini tetap dideteksi otomatis!
  static const Map<String, Map<String, FieldMapping>> customFieldMappings = {};

  /// Override penuh per endpoint jika butuh HTTP POST / body / header khusus per API.
  static const Map<String, EndpointConfig> customEndpoints = {};

  // ── PENGATURAN SISTEM (Tidak perlu diubah) ──────────────────────────────
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';
  static const Duration timeout = Duration(seconds: 15);
  static const bool enableDebugLog = kDebugMode;
  static const BoolRule boolRule = BoolRule();
  static const DateRule dateRule = DateRule(format: DateInputFormat.iso8601, toIsoString: true);

  /// Ambil konfigurasi endpoint list berdasarkan [type].
  static EndpointConfig getListEndpoint(String type) {
    final custom = customEndpoints[type];
    if (custom != null) return custom;

    return EndpointConfig(
      path: urls[type] ?? '/$type/',
      listPath: customListPaths[type] ?? '',
      fieldMapping: customFieldMappings[type] ?? const {},
    );
  }

  static final RegExp _detailPlaceholderRegex = RegExp(
    r'\{\{[^}]+\}\}|\$\{[^}]+\}|\{[^}]+\}|<[^>]+>|\[[^\]]+\]|(?<=[/=]):[a-zA-Z_][a-zA-Z0-9_]*|\$[a-zA-Z_][a-zA-Z0-9_]*',
  );

  /// Ganti berbagai gaya placeholder ID (`{game_id}`, `{{id}}`, `:id`, `<id>`, `[id]`, `$id`, `?id=`).
  static String resolveDetailUrl(String templateUrl, int id) {
    final trimmed = templateUrl.trim();
    final idStr = id.toString();
    if (_detailPlaceholderRegex.hasMatch(trimmed)) {
      return trimmed.replaceAll(_detailPlaceholderRegex, idStr);
    }
    if (trimmed.endsWith('=')) {
      return '$trimmed$idStr';
    }
    final withoutQuery = trimmed.split('?').first;
    return withoutQuery.endsWith('/') ? '$withoutQuery$idStr/' : '$withoutQuery/$idStr';
  }

  /// Ambil konfigurasi endpoint detail berdasarkan [type] dan [id].
  static EndpointConfig getDetailEndpoint(String type, int id) {
    final templateUrl = detailUrls[type];
    final String resolvedUrl;

    if (templateUrl != null && templateUrl.isNotEmpty) {
      resolvedUrl = resolveDetailUrl(templateUrl, id);
    } else {
      final listUrl = urls[type] ?? buildUrl('/$type/');
      resolvedUrl = resolveDetailUrl(listUrl, id);
    }

    return EndpointConfig(
      path: resolvedUrl,
      fieldMapping: customFieldMappings[type] ?? const {},
    );
  }

  /// Gabungkan [baseUrl] dan [path] jika [path] masih relatif.
  static String buildUrl(String path) {
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$cleanBase$cleanPath';
  }
}
