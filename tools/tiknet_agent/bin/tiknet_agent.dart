import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Tiknet Local Router Provisioning Agent
/// Lightweight localhost daemon (port 9876) bridging Web PWA to MikroTik routers via TCP 8728.
void main(List<String> args) async {
  final port = int.tryParse(Platform.environment['TIKNET_AGENT_PORT'] ?? '9876') ?? 9876;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('========================================================');
  print('🚀 Tiknet Local Router Provisioning Agent v1.0.0');
  print('📡 Listening on http://localhost:$port');
  print('🔒 Ready to bridge Web PWA <-> MikroTik RouterOS (TCP 8728)');
  print('========================================================');

  await for (HttpRequest request in server) {
    _handleRequest(request);
  }
}

void _handleRequest(HttpRequest req) async {
  final res = req.response;

  // Add CORS & Private Network Access (PNA) headers for browser compatibility
  res.headers.set('Access-Control-Allow-Origin', '*');
  res.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
  res.headers.set('Access-Control-Allow-Private-Network', 'true');

  if (req.method == 'OPTIONS') {
    res.statusCode = HttpStatus.noContent;
    await res.close();
    return;
  }

  final path = req.uri.path;

  try {
    if (path == '/health' || path == '/') {
      _sendJson(res, {
        'status': 'ok',
        'service': 'tiknet-local-agent',
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else if (path == '/discover') {
      final routers = await _discoverLocalRouters();
      _sendJson(res, {
        'success': true,
        'routers': routers,
      });
    } else if (path == '/provision' && req.method == 'POST') {
      final bodyStr = await utf8.decodeStream(req);
      final body = jsonDecode(bodyStr) as Map<String, dynamic>;
      final result = await _executeProvisioning(body);
      _sendJson(res, result);
    } else {
      res.statusCode = HttpStatus.notFound;
      _sendJson(res, {'error': 'Endpoint not found'});
    }
  } catch (e) {
    res.statusCode = HttpStatus.internalServerError;
    _sendJson(res, {'error': e.toString()});
  }
}

void _sendJson(HttpResponse res, Map<String, dynamic> data) async {
  res.headers.contentType = ContentType.json;
  res.write(jsonEncode(data));
  await res.close();
}

Future<List<Map<String, dynamic>>> _discoverLocalRouters() async {
  final candidateIps = ['192.168.88.1', '192.168.0.1', '192.168.1.1', '10.0.0.1'];
  final List<Map<String, dynamic>> found = [];

  for (final ip in candidateIps) {
    try {
      final sock = await Socket.connect(ip, 8728, timeout: const Duration(milliseconds: 600));
      sock.destroy();
      found.add({
        'ip': ip,
        'port': 8728,
        'status': 'reachable',
        'type': 'MikroTik RouterOS',
      });
    } catch (_) {}
  }
  return found;
}

Future<Map<String, dynamic>> _executeProvisioning(Map<String, dynamic> payload) async {
  final gatewayIp = payload['gateway_ip']?.toString() ?? '192.168.88.1';
  final username = payload['username']?.toString() ?? 'admin';
  final password = payload['password']?.toString() ?? '';
  final newPassword = payload['new_password']?.toString();
  final scriptSource = payload['script_source']?.toString();

  final logs = <String>[];
  void log(String msg) {
    logs.add('[$gatewayIp] $msg');
    print('  -> $msg');
  }

  log('Starting Phase 1 ZTP over native socket...');

  Socket? socket;
  try {
    socket = await Socket.connect(gatewayIp, 8728, timeout: const Duration(seconds: 4));
    log('TCP Socket connected to $gatewayIp:8728');

    // 1. Authenticate
    final loginRes = await _sendSentence(socket, [
      '/login',
      '=name=$username',
      '=password=$password',
    ]);

    if (!loginRes.contains('!done')) {
      return {
        'success': false,
        'message': 'Échec d\'authentification sur le routeur.',
        'logs': logs,
      };
    }
    log('Authentication successful as "$username"');

    // 2. Set new password if requested
    if (newPassword != null && newPassword.isNotEmpty) {
      log('Updating system password...');
      await _sendSentence(socket, [
        '/password',
        '=old-password=$password',
        '=new-password=$newPassword',
      ]);
    }

    // 3. Inject & run script if provided
    if (scriptSource != null && scriptSource.isNotEmpty) {
      log('Injecting and running Phase 1 bootstrap script...');
      await _sendSentence(socket, [
        '/system/script/add',
        '=name=tiknet_ztp_p1',
        '=policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon',
        '=dont-require-permissions=yes',
        '=source=$scriptSource',
      ]);

      final runRes = await _sendSentence(socket, [
        '/system/script/run',
        '=number=tiknet_ztp_p1',
      ]);

      if (runRes.contains('!done')) {
        log('✅ Script Phase 1 executed successfully on router hardware!');
      }
    }

    return {
      'success': true,
      'message': 'Provisionnement Phase 1 exécuté avec succès sur le routeur !',
      'logs': logs,
    };
  } catch (e) {
    log('Error: $e');
    return {
      'success': false,
      'message': 'Erreur lors de la communication avec le routeur: $e',
      'logs': logs,
    };
  } finally {
    socket?.destroy();
  }
}

Future<List<String>> _sendSentence(Socket socket, List<String> words) async {
  final completer = Completer<List<String>>();
  final responseWords = <String>[];
  final buffer = <int>[];

  final sub = socket.listen((data) {
    buffer.addAll(data);
    final parsed = _parseBuffer(buffer);
    if (parsed.isNotEmpty) {
      responseWords.addAll(parsed);
      if (parsed.contains('!done') || parsed.contains('!trap')) {
        if (!completer.isCompleted) completer.complete(responseWords);
      }
    }
  }, onError: (e) {
    if (!completer.isCompleted) completer.complete(responseWords);
  }, onDone: () {
    if (!completer.isCompleted) completer.complete(responseWords);
  });

  final bytes = <int>[];
  for (final w in words) {
    final wb = utf8.encode(w);
    _encodeLength(wb.length, bytes);
    bytes.addAll(wb);
  }
  bytes.add(0);

  socket.add(bytes);
  await socket.flush();

  final res = await completer.future.timeout(const Duration(seconds: 5), onTimeout: () => responseWords);
  await sub.cancel();
  return res;
}

void _encodeLength(int len, List<int> bytes) {
  if (len < 0x80) {
    bytes.add(len);
  } else if (len < 0x4000) {
    bytes.add((len >> 8) | 0x80);
    bytes.add(len & 0xFF);
  } else if (len < 0x200000) {
    bytes.add((len >> 16) | 0xC0);
    bytes.add((len >> 8) & 0xFF);
    bytes.add(len & 0xFF);
  } else {
    bytes.add((len >> 24) | 0xE0);
    bytes.add((len >> 16) & 0xFF);
    bytes.add((len >> 8) & 0xFF);
    bytes.add(len & 0xFF);
  }
}

List<String> _parseBuffer(List<int> buffer) {
  final words = <String>[];
  int offset = 0;
  while (offset < buffer.length) {
    if (offset >= buffer.length) break;
    final b0 = buffer[offset];
    int len = 0;
    int bytesRead = 0;

    if ((b0 & 0x80) == 0) {
      len = b0;
      bytesRead = 1;
    } else if ((b0 & 0xC0) == 0x80) {
      if (offset + 1 >= buffer.length) break;
      len = ((b0 & 0x3F) << 8) | buffer[offset + 1];
      bytesRead = 2;
    } else if ((b0 & 0xE0) == 0xC0) {
      if (offset + 2 >= buffer.length) break;
      len = ((b0 & 0x1F) << 16) | (buffer[offset + 1] << 8) | buffer[offset + 2];
      bytesRead = 3;
    } else {
      if (offset + 3 >= buffer.length) break;
      len = ((b0 & 0x0F) << 24) | (buffer[offset + 1] << 16) | (buffer[offset + 2] << 8) | buffer[offset + 3];
      bytesRead = 4;
    }

    if (offset + bytesRead + len > buffer.length) break;
    offset += bytesRead;
    if (len > 0) {
      final wb = buffer.sublist(offset, offset + len);
      words.add(utf8.decode(wb, allowMalformed: true));
      offset += len;
    }
  }
  if (offset > 0) buffer.removeRange(0, offset);
  return words;
}
