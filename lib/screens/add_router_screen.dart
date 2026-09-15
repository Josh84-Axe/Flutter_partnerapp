import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../locator.dart';
import '../models/router_configuration_model.dart';
import '../providers/split/network_provider.dart';
import '../services/mikrotik_ztp_service.dart';
import '../services/api/api_config.dart';
import '../utils/error_message_helper.dart';

class AddRouterScreen extends StatefulWidget {
  final RouterConfigurationModel? args;
  const AddRouterScreen({super.key, this.args});

  @override
  State<AddRouterScreen> createState() => _AddRouterScreenState();
}

class _AddRouterScreenState extends State<AddRouterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _radiusSecretController = TextEditingController();
  final _scrollController = ScrollController();

  // Terminal & Gateway controls
  final _gatewayIpController = TextEditingController(text: '192.168.88.1');
  final _adminUserCtrl = TextEditingController(text: 'admin');
  final _adminPassCtrl = TextEditingController();

  late final MikrotikZtpService _ztpService;

  // Constants — not shown to user, always sent to API
  static const int _apiPort = 8728;
  static const int _coaPort = 3799;

  RouterConfigurationModel? _existingConfig;

  // Server response & ZTP state
  Map<String, dynamic>? _serverResponse;

  // Live Telemeter State
  final List<String> _liveTerminalLogs = [];
  bool _isAuthenticating = false;
  bool _obscureAdminPass = true;
  bool _isRouterAuthenticated = false;
  Timer? _registrationPoller;
  String _routerOnlineStatus = 'pending'; // 'pending', 'handshake', 'online'

  @override
  void initState() {
    super.initState();
    _ztpService = locator<MikrotikZtpService>();

    _addLog('ztp_log_assistant_initialized'.tr());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = widget.args ?? ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is RouterConfigurationModel) {
        setState(() {
          _existingConfig = args;
          _nameController.text = args.name;
          _passwordController.text = args.password ?? '';
          _radiusSecretController.text = args.radiusSecret ?? '';
          _adminPassCtrl.text = args.password ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _registrationPoller?.cancel();
    _nameController.dispose();
    _passwordController.dispose();
    _radiusSecretController.dispose();
    _gatewayIpController.dispose();
    _adminUserCtrl.dispose();
    _adminPassCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    final timeStr = DateFormat('HH:mm:ss').format(DateTime.now());
    final entry = '[$timeStr] $message';
    setState(() {
      _liveTerminalLogs.add(entry);
      if (_liveTerminalLogs.length > 300) {
        _liveTerminalLogs.removeAt(0);
      }
    });
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    final networkProvider = context.read<NetworkProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final isEdit = _existingConfig != null;

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'password': _passwordController.text,
      'secret': _radiusSecretController.text.trim().isEmpty ? 'Raduis@Secret' : _radiusSecretController.text.trim(),
      'api_port': _apiPort,
      'coa_port': _coaPort,
      'is_active': true,
    };

    try {
      _addLog('saving_config_backend'.tr());
      Map<String, dynamic>? response;
      if (isEdit) {
        response = await networkProvider.updateRouter(_existingConfig!.slug, data);
      } else {
        response = await networkProvider.addRouter(data);
      }

      if (mounted) {
        setState(() {
          _serverResponse = response;
          _adminPassCtrl.text = _passwordController.text;
        });

        _addLog('ztp_log_config_saved'.tr());
        _startRegistrationPoller();

        // Scroll to reveal the ZTP actions panel
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'router_config_updated'.tr() : 'router_config_saved'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      final errorMsg = ErrorMessageHelper.getDetailedError(e);
      _addLog('❌ $errorMsg');
      messenger.showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _startRegistrationPoller() {
    _registrationPoller?.cancel();

    _registrationPoller = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      try {
        final netProv = context.read<NetworkProvider>();
        await netProv.loadRouters();
        final routers = netProv.routers;
        final rName = _nameController.text.trim().toLowerCase();

        final match = routers.where((r) => r.name.toLowerCase() == rName).firstOrNull;
        if (match != null) {
          if (match.status.toLowerCase() == 'online') {
            if (_routerOnlineStatus != 'online') {
              setState(() => _routerOnlineStatus = 'online');
              _addLog('ztp_log_canary_online'.tr(namedArgs: {'name': match.name}));
            }
          } else if (match.status.toLowerCase() == 'handshake') {
            setState(() => _routerOnlineStatus = 'handshake');
            _addLog('tunnel_detected_log'.tr());
          }
        }
      } catch (_) {}
    });
  }

  void _copyToClipboard(String text, {String? feedback}) {
    final fb = feedback ?? 'network_log_copied'.tr();
    Clipboard.setData(ClipboardData(text: text));
    _addLog('ztp_log_command_copied'.tr());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fb),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Run verification of credentials against target router gateway
  Future<void> _verifyRouterCredentials() async {
    final gatewayIp = _gatewayIpController.text.trim().isNotEmpty ? _gatewayIpController.text.trim() : '192.168.88.1';
    final user = _adminUserCtrl.text.trim().isNotEmpty ? _adminUserCtrl.text.trim() : 'admin';
    final pass = _adminPassCtrl.text;

    setState(() => _isAuthenticating = true);
    _addLog('auth_check_log'.tr(namedArgs: {'user': user, 'gateway': gatewayIp}));

    try {
      final success = await _ztpService.validateRouterCredentials(
        gatewayIp: gatewayIp,
        username: user,
        password: pass,
        onLog: (line) => _addLog(line),
      );

      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _isRouterAuthenticated = success;
        });
        if (success) {
          _addLog('ztp_log_auth_success'.tr(namedArgs: {'gateway': gatewayIp}));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ztp_log_auth_success_msg'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _addLog('ztp_log_auth_error'.tr(namedArgs: {'gateway': gatewayIp}));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ztp_log_auth_error_msg'.tr()),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAuthenticating = false);
        _addLog('ztp_log_auth_exception'.tr(namedArgs: {'error': e.toString()}));
      }
    }
  }

  /// Launch RouterOS WebFig Direct Terminal
  Future<void> _openWebFigTerminal() async {
    final ip = _gatewayIpController.text.trim().isNotEmpty ? _gatewayIpController.text.trim() : '192.168.88.1';
    final url = 'http://$ip/webfig/#Terminal';
    _addLog('opening_webfig_log'.tr(namedArgs: {'url': url}));
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _addLog('browser_open_error_log'.tr(namedArgs: {'error': e.toString()}));
    }
  }

  /// Opens the In-App Interactive Terminal Dialog with Socket Sentence Dispatcher
  void _openInteractiveTerminalModal(BuildContext context, String gatewayIp) {
    final TextEditingController cmdController = TextEditingController();
    final user = _adminUserCtrl.text.trim().isNotEmpty ? _adminUserCtrl.text.trim() : 'admin';

    final List<String> terminalOutput = [
      '============================================================',
      ' MikroTik RouterOS Interactive Terminal Console',
      ' Target Gateway IP: $gatewayIp',
      ' Connected User   : $user',
      ' Platform Mode    : ${kIsWeb ? "Web PWA" : "Native Mobile TCP Socket (Port 8728)"}',
      '============================================================',
      'ztp_log_ready_prompt'.tr(namedArgs: {'user': user}),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (stCtx, setModalState) {
            return Container(
              height: MediaQuery.of(modalCtx).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFF020617),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)],
              ),
              child: Column(
                children: [
                  // Terminal Header Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.terminal, color: Color(0xFF38BDF8), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${'direct_mikrotik_terminal'.tr()} [$gatewayIp]',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'direct_console_badge'.tr(),
                            style: const TextStyle(fontSize: 10, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.of(modalCtx).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Quick Action Toolbar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: const Color(0xFF1E293B),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              final cmd = _buildZtpCommand();
                              final token = _extractBootstrapToken();
                              cmdController.text = cmd;
                              _copyToClipboard(cmd);
                              setModalState(() {
                                terminalOutput.add('[$user@MikroTik] > $cmd');
                                terminalOutput.add('ztp_log_executing_ztp'.tr());
                              });

                              final payload = _serverResponse ?? {
                                'bootstrap_token': token,
                                'router_name': _nameController.text.trim(),
                              };

                              final res = await _ztpService.executeZtpProvisioning(
                                gatewayIp: gatewayIp,
                                ztpPayload: payload,
                                defaultAdminUsername: user,
                                defaultAdminPassword: _adminPassCtrl.text,
                                onProgress: (status, prog) {
                                  setModalState(() {
                                    terminalOutput.add('⏳ $status (${(prog * 100).toInt()}%)');
                                  });
                                },
                                onLog: (line) {
                                  setModalState(() {
                                    terminalOutput.add(line);
                                  });
                                },
                              );

                              setModalState(() {
                                terminalOutput.add(res ? 'ztp_log_exec_success'.tr() : 'ztp_log_exec_remarks'.tr());
                              });
                            },
                            icon: const Icon(Icons.flash_on, size: 14, color: Colors.black),
                            label: Text('paste_and_execute_ztp'.tr(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF38BDF8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              setModalState(() => cmdController.text = '/system identity print');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('/system identity print', style: TextStyle(fontSize: 10, fontFamily: 'monospace')),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton(
                            onPressed: () {
                              setModalState(() => cmdController.text = '/ip dhcp-client print');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('/ip dhcp-client print', style: TextStyle(fontSize: 10, fontFamily: 'monospace')),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Terminal Output View
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFF020617),
                      child: SingleChildScrollView(
                        reverse: true,
                        child: SelectableText(
                          terminalOutput.join('\n'),
                          style: const TextStyle(
                            color: Color(0xFF4ADE80),
                            fontSize: 12,
                            fontFamily: 'monospace',
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Terminal Input Line
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    color: const Color(0xFF0F172A),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Text('[$user@MikroTik] > ', style: const TextStyle(color: Color(0xFF38BDF8), fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13)),
                          Expanded(
                            child: TextField(
                              controller: cmdController,
                              style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 13),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'type_routeros_cmd_hint'.tr(),
                                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                              ),
                              onSubmitted: (val) async {
                                final cmd = val.trim();
                                if (cmd.isEmpty) return;
                                cmdController.clear();
                                setModalState(() {
                                  terminalOutput.add('[$user@MikroTik] > $cmd');
                                  terminalOutput.add('ztp_log_executing_cmd'.tr());
                                });
                                _addLog('💻 [Terminal Exec] $cmd');

                                final payload = _serverResponse ?? {
                                  'bootstrap_token': _extractBootstrapToken(),
                                  'router_name': _nameController.text.trim(),
                                  'payload_script': cmd,
                                };

                                final res = await _ztpService.executeZtpProvisioning(
                                  gatewayIp: gatewayIp,
                                  ztpPayload: payload,
                                  defaultAdminUsername: user,
                                  defaultAdminPassword: _adminPassCtrl.text,
                                  onProgress: (status, prog) {
                                    setModalState(() {
                                      terminalOutput.add('⏳ $status');
                                    });
                                  },
                                  onLog: (line) {
                                    setModalState(() {
                                      terminalOutput.add(line);
                                    });
                                  },
                                );

                                setModalState(() {
                                  terminalOutput.add(res ? 'ztp_log_cmd_success'.tr() : 'ztp_log_cmd_finished'.tr());
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Color(0xFF38BDF8), size: 18),
                            onPressed: () async {
                              final cmd = cmdController.text.trim();
                              if (cmd.isEmpty) return;
                              cmdController.clear();
                              setModalState(() {
                                terminalOutput.add('[$user@MikroTik] > $cmd');
                                terminalOutput.add('ztp_log_executing_cmd'.tr());
                              });
                              _addLog('💻 [Terminal Exec] $cmd');

                              final payload = _serverResponse ?? {
                                'bootstrap_token': _extractBootstrapToken(),
                                'router_name': _nameController.text.trim(),
                                'payload_script': cmd,
                              };

                              final res = await _ztpService.executeZtpProvisioning(
                                gatewayIp: gatewayIp,
                                ztpPayload: payload,
                                defaultAdminUsername: user,
                                defaultAdminPassword: _adminPassCtrl.text,
                                onProgress: (status, prog) {
                                  setModalState(() {
                                    terminalOutput.add('⏳ $status');
                                  });
                                },
                                onLog: (line) {
                                  setModalState(() {
                                    terminalOutput.add(line);
                                  });
                                },
                              );

                              setModalState(() {
                                terminalOutput.add(res ? 'ztp_log_cmd_success'.tr() : 'ztp_log_cmd_finished'.tr());
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _extractBootstrapToken() {
    if (_serverResponse != null) {
      Map<String, dynamic> rData = _serverResponse!;
      while (rData.containsKey('data') && rData['data'] is Map) {
        rData = rData['data'] as Map<String, dynamic>;
      }
      final token = rData['bootstrap_token']?.toString();
      if (token != null && token.trim().isNotEmpty) return token.trim();
      final slug = rData['slug']?.toString();
      if (slug != null && slug.trim().isNotEmpty) return slug.trim();
      final name = _nameController.text.trim().toLowerCase();
      if (name.isNotEmpty) return name;
    }
    final token = _existingConfig?.bootstrapToken;
    if (token != null && token.trim().isNotEmpty) return token.trim();
    final slug = _existingConfig?.slug;
    if (slug != null && slug.trim().isNotEmpty) return slug.trim();
    return _nameController.text.trim().toLowerCase();
  }

  String _buildZtpCommand() {
    final token = _extractBootstrapToken();
    return ':if ([/ip dhcp-client find interface=ether1] = "") do={ :do { /ip dhcp-client add interface=ether1 add-default-route=yes use-peer-dns=yes disabled=no } on-error={} }; /tool fetch url="${ApiConfig.baseUrl}/bootstrap/$token/" check-certificate=yes-without-crl dst-path=bootstrap.rsc keep-result=yes; :delay 2s; /import file-name=bootstrap.rsc;';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existingConfig != null;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<NetworkProvider>();

    final hasConfig = isEdit || _serverResponse != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'edit_router'.tr() : 'add_new_router'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all, size: 20),
            tooltip: 'copy_diagnostic_logs_tooltip'.tr(),
            onPressed: () => _copyToClipboard(_liveTerminalLogs.join('\n'), feedback: 'telemetry_log_copied'.tr()),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. ROUTER REGISTRATION FORM
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.router, color: Colors.indigo, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ztp_hardware_config'.tr(),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                                    ),
                                    Text(
                                      'ztp_hardware_config_desc'.tr(),
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Wi-Fi Name Input
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'router_name_wifi_ssid'.tr(),
                              hintText: 'router_name_hint'.tr(),
                              prefixIcon: const Icon(Icons.wifi),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'enter_wifi_name'.tr();
                              if (value.contains('_')) return 'wifi_name_underscore_error'.tr();
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton.icon(
                              onPressed: provider.isLoading ? null : _saveConfiguration,
                              icon: provider.isLoading
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.check_circle_outline, size: 20),
                              label: Text(
                                provider.isLoading
                                    ? 'saving_in_progress'.tr()
                                    : (hasConfig ? 'update_configuration'.tr() : 'save_configuration'.tr()),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. ROUTER AUTHENTICATION & DIRECT TERMINAL PROVISIONING
                    if (hasConfig) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Header with Status Badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.security, color: Color(0xFF0284C7), size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'auth_and_terminal_title'.tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        'ztp_access_router_desc'.tr(),
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _routerOnlineStatus == 'online'
                                        ? Colors.green.withValues(alpha: 0.15)
                                        : Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _routerOnlineStatus == 'online' ? Colors.green : Colors.amber,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _routerOnlineStatus == 'online' ? Icons.check_circle : Icons.sync,
                                        color: _routerOnlineStatus == 'online' ? Colors.green : Colors.amber,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _routerOnlineStatus == 'online'
                                            ? 'online_status_badge'.tr()
                                            : (_routerOnlineStatus == 'handshake' ? 'wireguard_connected'.tr() : 'pending_status'.tr()),
                                        style: TextStyle(
                                          color: _routerOnlineStatus == 'online' ? Colors.green : Colors.amber,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Inputs Row 1: Gateway IP & Username
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _gatewayIpController,
                                    onChanged: (_) {
                                      if (_isRouterAuthenticated) setState(() => _isRouterAuthenticated = false);
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'gateway_ip_label'.tr(),
                                      hintText: '192.168.88.1',
                                      isDense: true,
                                      prefixIcon: const Icon(Icons.lan_outlined, size: 18),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _adminUserCtrl,
                                    onChanged: (_) {
                                      if (_isRouterAuthenticated) setState(() => _isRouterAuthenticated = false);
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'username_label'.tr(),
                                      hintText: 'admin',
                                      isDense: true,
                                      prefixIcon: const Icon(Icons.person_outline, size: 18),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Input Row 2: Admin Password
                            TextFormField(
                              controller: _adminPassCtrl,
                              obscureText: _obscureAdminPass,
                              onChanged: (_) {
                                if (_isRouterAuthenticated) setState(() => _isRouterAuthenticated = false);
                              },
                              decoration: InputDecoration(
                                labelText: 'admin_password_label'.tr(),
                                hintText: 'admin_password_hint'.tr(),
                                isDense: true,
                                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureAdminPass ? Icons.visibility_off : Icons.visibility,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscureAdminPass = !_obscureAdminPass);
                                  },
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Action Buttons: Tester Auth & Ouvrir Terminal
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: OutlinedButton.icon(
                                    onPressed: _isAuthenticating ? null : _verifyRouterCredentials,
                                    icon: _isAuthenticating
                                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                        : Icon(
                                            _isRouterAuthenticated ? Icons.check_circle : Icons.shield_outlined,
                                            size: 18,
                                            color: _isRouterAuthenticated ? Colors.green : null,
                                          ),
                                    label: Text(
                                      _isAuthenticating
                                          ? 'testing_in_progress'.tr()
                                          : (_isRouterAuthenticated ? 'authenticated_status'.tr() : 'test_auth_button'.tr()),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: _isRouterAuthenticated ? Colors.green : null,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      side: BorderSide(
                                        color: _isRouterAuthenticated ? Colors.green : colorScheme.outline.withValues(alpha: 0.3),
                                      ),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: FilledButton.icon(
                                    onPressed: _isRouterAuthenticated
                                        ? () => _openInteractiveTerminalModal(
                                              context,
                                              _gatewayIpController.text.trim().isNotEmpty ? _gatewayIpController.text.trim() : '192.168.88.1',
                                            )
                                        : null,
                                    icon: Icon(
                                      _isRouterAuthenticated ? Icons.terminal : Icons.lock_outline,
                                      size: 18,
                                      color: _isRouterAuthenticated ? Colors.black : Colors.white54,
                                    ),
                                    label: Text(
                                      _isRouterAuthenticated ? 'terminal_one_click_ztp'.tr() : 'locked_auth_required'.tr(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: _isRouterAuthenticated ? Colors.black : Colors.white54,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF38BDF8),
                                      disabledBackgroundColor: Colors.grey.shade800,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: _isRouterAuthenticated ? 3 : 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Subtle WebFig Link
                            Center(
                              child: TextButton.icon(
                                onPressed: _openWebFigTerminal,
                                icon: const Icon(Icons.open_in_new, size: 14, color: Colors.grey),
                                label: Text(
                                  'open_external_webfig'.tr(),
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
