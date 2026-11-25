import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// User-Agent sent to every metadata/cover provider. Open Library and
/// Inventaire ask clients to identify themselves with a contact URL.
const String kUserAgent = 'Openshelf (+https://github.com/Swappppy/Openshelf)';

const Map<String, String> kDefaultHeaders = {'User-Agent': kUserAgent};

/// User-Agent sent only to Open Library (including its covers host). Its API
/// guidelines ask for a contact email, which is not shared with other providers.
const String kOpenLibraryUserAgent = 'Openshelf (openshelf@tuta.com)';

/// Request headers for [uri], choosing the provider-specific User-Agent.
Map<String, String> headersFor(Uri uri) => {
      'User-Agent': uri.host.endsWith('openlibrary.org')
          ? kOpenLibraryUserAgent
          : kUserAgent,
    };

/// Downloads [url] with a timeout and a hard size cap, so a slow or
/// malicious server cannot hang the UI or exhaust memory.
///
/// Returns `null` on non-200 responses, non-image content (when
/// [requireImage] is set), timeouts or oversized bodies.
Future<Uint8List?> downloadBytes(
  String url, {
  Duration timeout = const Duration(seconds: 20),
  int maxBytes = 15 * 1024 * 1024,
  bool requireImage = true,
  http.Client? client,
}) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !(uri.scheme == 'https' || uri.scheme == 'http')) return null;

  final c = client ?? http.Client();
  try {
    final request = http.Request('GET', uri)..headers.addAll(headersFor(uri));
    final response = await c.send(request).timeout(timeout);
    if (response.statusCode != 200) return null;

    final type = response.headers['content-type'] ?? '';
    if (requireImage && type.isNotEmpty && !type.startsWith('image/') && !type.startsWith('application/octet-stream')) {
      return null;
    }
    if ((response.contentLength ?? 0) > maxBytes) return null;

    final builder = BytesBuilder(copy: false);
    await for (final chunk in response.stream.timeout(timeout)) {
      builder.add(chunk);
      if (builder.length > maxBytes) return null;
    }
    return builder.takeBytes();
  } on TimeoutException {
    return null;
  } finally {
    if (client == null) c.close();
  }
}
