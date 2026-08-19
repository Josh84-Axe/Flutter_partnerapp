import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Lightweight, native RouterOS TCP 8728 API Client in Dart.
/// Bypasses HTTP/REST and WebFig to execute commands directly on RouterOS socket.
class MikrotikApiSocket {
  Socket? _socket;
  StreamSubscription<Uint8List>? _socketSub;
  Completer<List<String>>? _activeCompleter;
  final List<String> _responseWords = [];
  final List<int> _readBuffer = [];

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

      _readBuffer.clear();
      _responseWords.clear();
      _socketSub = _socket!.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      final cleanUser = username.trim();
      final cleanPass = password.trim();

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

  void _onData(Uint8List data) {
    _readBuffer.addAll(data);
    final parsed = _parseSentences(_readBuffer);
    if (parsed.isNotEmpty) {
      _responseWords.addAll(parsed);
      if (parsed.contains('!done') || parsed.contains('!trap')) {
        if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
          _activeCompleter!.complete(List<String>.from(_responseWords));
        }
      }
    }
  }

  void _onError(dynamic err) {
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.completeError(err);
    }
  }

  void _onDone() {
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete(List<String>.from(_responseWords));
    }
  }

  /// Send arbitrary RouterOS API sentence
  Future<bool> sendSentence(List<String> words, {Duration timeout = const Duration(seconds: 4)}) async {
    try {
      final resp = await _sendSentenceAndReadResponse(words, timeout: timeout);
      return resp.any((w) => w == '!done');
    } catch (_) {
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
      final addSentence = [
        '/system/script/add',
        '=name=$scriptName',
        '=source=$scriptSource',
      ];
      final addResp = await _sendSentenceAndReadResponse(addSentence, timeout: timeout);
      final addOk = addResp.any((w) => w == '!done');

      if (!addOk) {
        final setSentence = [
          '/system/script/set',
          '=numbers=$scriptName',
          '=source=$scriptSource',
        ];
        await _sendSentenceAndReadResponse(setSentence, timeout: timeout);
      }

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
      _socketSub?.cancel();
    } catch (_) {}
    try {
      _socket?.destroy();
    } catch (_) {}
    _socketSub = null;
    _socket = null;
  }

  // --- RouterOS API Protocol Framing Helpers ---

  Future<List<String>> _sendSentenceAndReadResponse(List<String> words, {required Duration timeout}) async {
    if (_socket == null) return [];

    _responseWords.clear();
    _activeCompleter = Completer<List<String>>();

    final bytes = <int>[];
    for (final word in words) {
      final wordBytes = utf8.encode(word);
      _encodeLength(wordBytes.length, bytes);
      bytes.addAll(wordBytes);
    }
    bytes.add(0); // End of sentence marker

    _socket!.add(Uint8List.fromList(bytes));
    await _socket!.flush();

    return _activeCompleter!.future.timeout(timeout, onTimeout: () {
      return List<String>.from(_responseWords);
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
      if (lenResult == null) break;

      final len = lenResult['length'] as int;
      final lenBytesRead = lenResult['bytesRead'] as int;

      if (offset + lenBytesRead + len > buffer.length) {
        break;
      }

      offset += lenBytesRead;

      if (len == 0) {
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
