import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Lightweight, native RouterOS TCP 8728 API Client in Dart.
/// Bypasses HTTP/REST and WebFig to execute commands directly on RouterOS socket.
class MikrotikApiSocket {
  Socket? _socket;
  final String host;
  final int port;

  MikrotikApiSocket({
    required this.host,
    this.port = 8728,
  });

  /// Connect and authenticate using RouterOS 7.x API protocol
  Future<bool> connectAndLogin({
    required String username,
    required String password,
    Duration timeout = const Duration(seconds: 4),
    Function(String logLine)? onLog,
  }) async {
    void log(String msg) {
      onLog?.call(msg);
      if (kDebugMode) debugPrint('🔌 [MikrotikApiSocket] $msg');
    }

    try {
      log('Connecting to TCP socket $host:$port (timeout: ${timeout.inSeconds}s)...');
      _socket = await Socket.connect(host, port, timeout: timeout);
      log('Connected to TCP $host:$port!');

      final cleanUser = username.trim();
      final cleanPass = password.trim();

      // RouterOS 7.x Plain Login Sentence:
      // /login
      // =name=admin
      // =password=EWQCI2IHXX
      final loginSentence = [
        '/login',
        '=name=$cleanUser',
        '=password=$cleanPass',
      ];

      log('Sending login sentence to $host:$port for user "$cleanUser"...');
      final response = await _sendSentenceAndReadResponse(loginSentence, timeout: timeout);
      log('Received raw socket response from $host:$port: ${response.join(" ")}');

      final isDone = response.any((word) => word == '!done');
      final isTrap = response.any((word) => word == '!trap');
      if (isDone) {
        log('SUCCESS: RouterOS returned !done for user "$cleanUser"');
        return true;
      } else if (isTrap) {
        log('REJECTED: RouterOS returned !trap (invalid username or password)');
        return false;
      }

      return false;
    } catch (e) {
      log('SOCKET ERROR on $host:$port -> $e');
      return false;
    }
  }

  /// Read System Identity from RouterOS API
  Future<String?> getSystemIdentity({Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final resp = await _sendSentenceAndReadResponse(['/system/identity/print'], timeout: timeout);
      for (final word in resp) {
        if (word.startsWith('=name=')) {
          return word.substring(6);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Create and execute script on RouterOS API
  Future<bool> executeScript({
    required String scriptName,
    required String scriptSource,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      // 1. /system/script/add =name=scriptName =source=scriptSource
      final addSentence = [
        '/system/script/add',
        '=name=$scriptName',
        '=source=$scriptSource',
      ];
      final addResp = await _sendSentenceAndReadResponse(addSentence, timeout: timeout);
      final addOk = addResp.any((w) => w == '!done');

      if (!addOk) {
        // If script already exists, set source instead
        final setSentence = [
          '/system/script/set',
          '=numbers=$scriptName',
          '=source=$scriptSource',
        ];
        await _sendSentenceAndReadResponse(setSentence, timeout: timeout);
      }

      // 2. /system/script/run =number=scriptName
      final runSentence = [
        '/system/script/run',
        '=number=$scriptName',
      ];
      final runResp = await _sendSentenceAndReadResponse(runSentence, timeout: timeout);
      return runResp.any((w) => w == '!done');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [MikrotikApiSocket] Script execution error: $e');
      }
      return false;
    }
  }

  /// Close connection
  void close() {
    try {
      _socket?.destroy();
    } catch (_) {}
    _socket = null;
  }

  // --- RouterOS API Protocol Framing Helpers ---

  Future<List<String>> _sendSentenceAndReadResponse(List<String> words, {required Duration timeout}) async {
    if (_socket == null) return [];

    final bytes = <int>[];
    for (final word in words) {
      final wordBytes = utf8.encode(word);
      _encodeLength(wordBytes.length, bytes);
      bytes.addAll(wordBytes);
    }
    bytes.add(0); // End of sentence marker

    _socket!.add(Uint8List.fromList(bytes));
    await _socket!.flush();

    final completer = Completer<List<String>>();
    final responseWords = <String>[];
    final buffer = <int>[];

    late StreamSubscription<Uint8List> sub;
    sub = _socket!.listen(
      (data) {
        buffer.addAll(data);
        final parsed = _parseSentences(buffer);
        if (parsed.isNotEmpty) {
          responseWords.addAll(parsed);
          if (parsed.contains('!done') || parsed.contains('!trap')) {
            sub.cancel();
            if (!completer.isCompleted) completer.complete(responseWords);
          }
        }
      },
      onError: (err) {
        sub.cancel();
        if (!completer.isCompleted) completer.completeError(err);
      },
      onDone: () {
        sub.cancel();
        if (!completer.isCompleted) completer.complete(responseWords);
      },
    );

    return completer.future.timeout(timeout, onTimeout: () {
      sub.cancel();
      return responseWords;
    });
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
    } else if (len < 0x10000000) {
      bytes.add((len >> 24) | 0xE0);
      bytes.add((len >> 16) & 0xFF);
      bytes.add((len >> 8) & 0xFF);
      bytes.add(len & 0xFF);
    }
  }

  List<String> _parseSentences(List<int> buffer) {
    final words = <String>[];
    int offset = 0;

    while (offset < buffer.length) {
      final lenResult = _decodeLength(buffer, offset);
      if (lenResult == null) break; // Incomplete length byte

      final len = lenResult['length'] as int;
      final lenBytesRead = lenResult['bytesRead'] as int;

      if (offset + lenBytesRead + len > buffer.length) {
        break; // Incomplete word bytes
      }

      offset += lenBytesRead;

      if (len == 0) {
        // End of sentence
        continue;
      }

      final wordBytes = buffer.sublist(offset, offset + len);
      words.add(utf8.decode(wordBytes, allowMalformed: true));
      offset += len;
    }

    if (offset > 0) {
      buffer.removeRange(0, offset);
    }

    return words;
  }

  Map<String, int>? _decodeLength(List<int> buffer, int offset) {
    if (offset >= buffer.length) return null;
    final b0 = buffer[offset];

    if ((b0 & 0x80) == 0) {
      return {'length': b0, 'bytesRead': 1};
    } else if ((b0 & 0xC0) == 0x80) {
      if (offset + 1 >= buffer.length) return null;
      final b1 = buffer[offset + 1];
      return {'length': ((b0 & 0x3F) << 8) | b1, 'bytesRead': 2};
    } else if ((b0 & 0xE0) == 0xC0) {
      if (offset + 2 >= buffer.length) return null;
      final b1 = buffer[offset + 1];
      final b2 = buffer[offset + 2];
      return {'length': ((b0 & 0x1F) << 16) | (b1 << 8) | b2, 'bytesRead': 3};
    } else if ((b0 & 0xF0) == 0xE0) {
      if (offset + 3 >= buffer.length) return null;
      final b1 = buffer[offset + 1];
      final b2 = buffer[offset + 2];
      final b3 = buffer[offset + 3];
      return {'length': ((b0 & 0x0F) << 24) | (b1 << 16) | (b2 << 8) | b3, 'bytesRead': 4};
    }
    return null;
  }
}
