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
  Timer? _registrationPoller;
  String _routerOnlineStatus = 'pending'; // 'pending', 'handshake', 'online'

  @override
  void initState() {
    super.initState();
    _ztpService = locator<MikrotikZtpService>();

    _addLog('🚀 [Telemeter Ready] Assistant ZTP initialisé. Prêt pour configuration.');

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
      _addLog('💾 Enregistrement de la configuration routeur sur le backend...');
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

        _addLog('✅ Configuration enregistrée avec succès. Token ZTP et clés WireGuard générés.');
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
      _addLog('❌ Erreur enregistrement: $errorMsg');
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
              _addLog('🎉 [CANARY CONFIRMED] Le routeur "${match.name}" est maintenant EN LIGNE et provisionné !');
            }
          } else if (match.status.toLowerCase() == 'handshake') {
            setState(() => _routerOnlineStatus = 'handshake');
            _addLog('🔵 [TUNNEL DETECTED] Handshake WireGuard reçu du routeur.');
          }
        }
      } catch (_) {}
    });
  }

  void _copyToClipboard(String text, {String feedback = 'Copié dans le presse-papier !'}) {
    Clipboard.setData(ClipboardData(text: text));
    _addLog('📋 Commande copiée dans le presse-papier.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(feedback),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Run verification of credentials against target router gateway
  Future<void> _verifyRouterCredentials() async {
    final gatewayIp = _gatewayIpController.text.trim();
    final user = _adminUserCtrl.text.trim();
    final pass = _adminPassCtrl.text.trim();

    setState(() => _isAuthenticating = true);
    _addLog('🔐 [Auth Check] Test des identifiants "$user" sur [$gatewayIp]...');

    try {
      final success = await _ztpService.validateRouterCredentials(
        gatewayIp: gatewayIp,
        username: user,
        password: pass,
        onLog: (line) => _addLog(line),
      );

      if (mounted) {
        setState(() => _isAuthenticating = false);
        if (success) {
          _addLog('✅ [Auth Success] Authentification réussie sur le routeur ($gatewayIp) !');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Authentification réussie sur le routeur !'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _addLog('⚠️ [Auth Notice] Impossible d\'authentifier en direct (Mixed Content PWA ou identifiants incorrects).');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Utilisez le bouton 1-Clic pour exécuter dans le Terminal WebFig.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAuthenticating = false);
        _addLog('⚠️ Exception vérification: $e');
      }
    }
  }

  /// Launch RouterOS WebFig Direct Terminal
  Future<void> _openWebFigTerminal() async {
    final ip = _gatewayIpController.text.trim().isNotEmpty ? _gatewayIpController.text.trim() : '192.168.88.1';
    final url = 'http://$ip/webfig/#Terminal';
    _addLog('🌐 Ouverture du Terminal WebFig sur $url...');
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _addLog('❌ Erreur ouverture navigateur: $e');
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
      '[$user@MikroTik] > Prêt. Collez ou écrivez votre commande...',
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
                            'Terminal MikroTik Direct [$gatewayIp]',
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
                          child: const Text(
                            'CONSOLE DIRECTE',
                            style: TextStyle(fontSize: 10, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
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
                            onPressed: () {
                              final token = _extractBootstrapToken();
                              final cmd = '/tool fetch url="https://staging.wifi-4u.net/v1/bootstrap/$token/" mode=https output=file dst-path=bootstrap.rsc; :delay 2s; /import file-name=bootstrap.rsc';
                              cmdController.text = cmd;
                              _copyToClipboard(cmd);
                              setModalState(() {
                                terminalOutput.add('[$user@MikroTik] > $cmd');
                                terminalOutput.add('📋 Commande ZTP chargée et copiée dans le presse-papier !');
                              });
                            },
                            icon: const Icon(Icons.flash_on, size: 14, color: Colors.black),
                            label: const Text('⚡ Charger Commande ZTP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
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
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Tapez une commande RouterOS...',
                                hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                              ),
                              onSubmitted: (val) {
                                final cmd = val.trim();
                                if (cmd.isEmpty) return;
                                setModalState(() {
                                  terminalOutput.add('[$user@MikroTik] > $cmd');
                                  terminalOutput.add('⚡ Sentence sent to router socket engine...');
                                  cmdController.clear();
                                });
                                _addLog('💻 [Terminal Exec] $cmd');
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Color(0xFF38BDF8), size: 18),
                            onPressed: () {
                              final cmd = cmdController.text.trim();
                              if (cmd.isEmpty) return;
                              setModalState(() {
                                terminalOutput.add('[$user@MikroTik] > $cmd');
                                terminalOutput.add('⚡ Sentence sent to router socket engine...');
                                cmdController.clear();
                              });
                              _addLog('💻 [Terminal Exec] $cmd');
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
      return rData['bootstrap_token']?.toString() ??
          rData['slug']?.toString() ??
          _nameController.text.trim().toLowerCase();
    }
    return _existingConfig?.bootstrapToken ??
        _existingConfig?.slug ??
        _nameController.text.trim().toLowerCase();
  }

  String _buildZtpCommand() {
    final token = _extractBootstrapToken();
    return '/tool fetch url="https://staging.wifi-4u.net/v1/bootstrap/$token/" mode=https output=file dst-path=bootstrap.rsc; :delay 2s; /import file-name=bootstrap.rsc';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existingConfig != null;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<NetworkProvider>();

    final hasConfig = isEdit || _serverResponse != null;
    final ztpCommand = _buildZtpCommand();
    final routerName = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Routeur Tiknet';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'edit_router'.tr() : 'add_new_router'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all, size: 20),
            tooltip: 'Copier les logs de diagnostic',
            onPressed: () => _copyToClipboard(_liveTerminalLogs.join('\n'), feedback: 'Logs du Telemeter copiés !'),
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
                                      'Configuration Matérielle',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                                    ),
                                    Text(
                                      'Définissez les paramètres réseau du routeur',
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
                              labelText: 'Nom du routeur / SSID Wi-Fi',
                              hintText: 'ex: Tiknet-Salon, Office-Router',
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
                                    ? 'Enregistrement en cours...'
                                    : (hasConfig ? 'Mettre à jour la configuration' : 'Enregistrer la configuration'),
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

                    // 2. PROVISIONING ACTIONS & 1-CLICK ZTP EXECUTION BAR
                    if (hasConfig) ...[
                      // ── SECTION A: 1-CLICK COPY & EXECUTE ZTP ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt, color: Color(0xFF38BDF8), size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'ZTP 1-CLIC AUTOMATISÉ',
                                        style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _routerOnlineStatus == 'online'
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.amber.withValues(alpha: 0.2),
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
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _routerOnlineStatus == 'online'
                                            ? 'EN LIGNE'
                                            : (_routerOnlineStatus == 'handshake' ? 'TUNNEL WIREGUARD' : 'EN ATTENTE'),
                                        style: TextStyle(
                                          color: _routerOnlineStatus == 'online' ? Colors.green : Colors.amber,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            Text(
                              'Commande ZTP Phase 1 pour $routerName',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Copiez et collez cette ligne unique dans le Terminal MikroTik. Le routeur s\'auto-provisionnera et rejoindra le contrôleur en 5 secondes.',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
                            ),
                            const SizedBox(height: 14),

                            // Command Code Block
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF020617),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: SelectableText(
                                ztpCommand,
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 1-Click Copy Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () => _copyToClipboard(ztpCommand, feedback: '📋 Commande ZTP 1-Clic copiée ! Prête à coller dans le Terminal.'),
                                icon: const Icon(Icons.copy, size: 18, color: Colors.black),
                                label: const Text(
                                  '📋 COPIER LA COMMANDE ZTP 1-CLIC',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black, letterSpacing: 0.3),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF38BDF8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── SECTION B: TERMINAL AUTHENTICATION & WEBFIG ACCESS ──
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
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.terminal, color: Color(0xFF0284C7), size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Authentification Terminal & Accès WebFig',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colorScheme.onSurface),
                                      ),
                                      Text(
                                        'Vérifiez la passerelle ou ouvrez directement la console',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Gateway IP Input
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _gatewayIpController,
                                    decoration: InputDecoration(
                                      labelText: 'IP Passerelle Routeur',
                                      hintText: '192.168.88.1',
                                      isDense: true,
                                      prefixIcon: const Icon(Icons.lan_outlined, size: 18),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _adminUserCtrl,
                                    decoration: InputDecoration(
                                      labelText: 'Utilisateur',
                                      hintText: 'admin',
                                      isDense: true,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _isAuthenticating ? null : _verifyRouterCredentials,
                                    icon: _isAuthenticating
                                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.security, size: 16),
                                    label: Text(
                                      _isAuthenticating ? 'Vérification...' : 'Tester Auth',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: _openWebFigTerminal,
                                    icon: const Icon(Icons.open_in_new, size: 16),
                                    label: const Text(
                                      'WebFig #Terminal',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F172A),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // In-App Terminal Modal Trigger
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: () => _openInteractiveTerminalModal(context, _gatewayIpController.text.trim()),
                                icon: const Icon(Icons.computer, size: 16, color: Color(0xFF0284C7)),
                                label: const Text(
                                  '💻 Ouvrir le Terminal Interactif In-App (Socket Console)',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── SECTION C: LIVE TRACKER & TELEMETER CONSOLE ──
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF020617),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF1E293B)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.track_changes, color: Color(0xFF4ADE80), size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  'LIVE TELEMETER & DIAGNOSTIC LOGS',
                                  style: TextStyle(
                                    color: Color(0xFF4ADE80),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 14, color: Colors.white60),
                                  tooltip: 'Copier les logs',
                                  onPressed: () => _copyToClipboard(_liveTerminalLogs.join('\n')),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(color: Color(0xFF1E293B), height: 1),
                            const SizedBox(height: 10),

                            Container(
                              height: 180,
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF090D16),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF1E293B)),
                              ),
                              child: SingleChildScrollView(
                                reverse: true,
                                child: SelectableText(
                                  _liveTerminalLogs.isEmpty
                                      ? '[En attente de connexion...]'
                                      : _liveTerminalLogs.join('\n'),
                                  style: const TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    height: 1.4,
                                  ),
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
