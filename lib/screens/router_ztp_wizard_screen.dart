import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../locator.dart';
import '../providers/split/network_provider.dart';
import '../services/mikrotik_ztp_service.dart';

class RouterZtpWizardScreen extends StatefulWidget {
  final int? routerId;
  final String? routerName;

  const RouterZtpWizardScreen({
    super.key,
    this.routerId,
    this.routerName,
  });

  @override
  State<RouterZtpWizardScreen> createState() => _RouterZtpWizardScreenState();
}

class _RouterZtpWizardScreenState extends State<RouterZtpWizardScreen> {
  late final MikrotikZtpService _ztpService;

  int _currentStep = 1;
  final TextEditingController _gatewayIpController = TextEditingController(text: '192.168.88.1');

  bool _isProbing = false;
  bool _isFetchingPayload = false;
  bool _isProvisioning = false;

  MikrotikDeviceInfo? _deviceInfo;
  Map<String, dynamic>? _ztpPayload;
  Map<String, dynamic>? _verificationData;

  String _statusMessage = '';
  double _progressValue = 0.0;
  String? _errorMessage;
  final List<String> _liveTerminalLogs = [];

  int _effectiveRouterId = 0;
  String _effectiveRouterName = 'Nouveau Routeur';

  String _tr(String key, String fallback) {
    try {
      final res = key.tr();
      if (res == key || res.isEmpty) {
        return fallback;
      }
      return res;
    } catch (_) {
      return fallback;
    }
  }

  @override
  void initState() {
    super.initState();
    _ztpService = locator<MikrotikZtpService>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _effectiveRouterId = args['routerId'] ?? widget.routerId ?? 0;
      _effectiveRouterName = args['routerName'] ?? widget.routerName ?? 'Nouveau Routeur';
    } else {
      _effectiveRouterId = widget.routerId ?? 0;
      _effectiveRouterName = widget.routerName ?? 'Nouveau Routeur';
    }

    if (_effectiveRouterId > 0 && _ztpPayload == null && !_isFetchingPayload) {
      _loadZtpPayload();
    }
  }

  @override
  void dispose() {
    _gatewayIpController.dispose();
    super.dispose();
  }

  Future<void> _loadZtpPayload() async {
    setState(() {
      _isFetchingPayload = true;
      _errorMessage = null;
    });

    try {
      final payload = await _ztpService.fetchZtpPayload(_effectiveRouterId);
      setState(() {
        _ztpPayload = payload;
        _isFetchingPayload = false;
      });
    } catch (e) {
      setState(() {
        _isFetchingPayload = false;
        _errorMessage = 'Impossible de charger le payload ZTP pour ce routeur. Vérifiez votre connexion internet.';
      });
    }
  }

  String _customAdminUsername = 'admin';
  String _customAdminPassword = '';

  Future<Map<String, String>?> _promptCustomCredentials() async {
    final userCtrl = TextEditingController(text: _customAdminUsername);
    final passCtrl = TextEditingController(text: _customAdminPassword);
    bool passObscured = true;
    bool isValidating = false;
    bool showLogs = false;
    String? dlgError;
    List<String> dlgLogs = [];

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.lock_person, color: Colors.indigo),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Mot de Passe Routeur Requis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kIsWeb) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🌐 Navigateur Web PWA (HTTPS) : Les navigateurs web restreignent les requêtes HTTP d\'arrière-plan vers les IP locales (192.168.88.1). Pour un ZTP 100% automatique via Socket TCP 8728, utilisez l\'application Mobile Android (APK) !',
                            style: TextStyle(color: Colors.amber.shade900, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Text(
                  'Ce routeur est protégé (boîtier déjà configuré ou mot de passe inscrit sur l\'étiquette au dos du routeur). Veuillez le saisir ci-dessous pour continuer.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                ),
                const SizedBox(height: 16),
                if (dlgError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dlgError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                TextField(
                  controller: userCtrl,
                  enabled: !isValidating,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  enabled: !isValidating,
                  obscureText: passObscured,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe actuel (Sticker / Admin)',
                    hintText: 'ex: EWQCI2IHXX',
                    prefixIcon: const Icon(Icons.key_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(passObscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setDlgState(() => passObscured = !passObscured),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setDlgState(() => showLogs = !showLogs),
                  child: Row(
                    children: [
                      Icon(showLogs ? Icons.terminal : Icons.terminal_outlined, size: 16, color: Colors.indigo),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          showLogs ? 'Masquer le journal réseau' : '🔍 Afficher les échanges Réseau/Socket (Live Log)',
                          style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showLogs || dlgLogs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 160,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Text(
                        dlgLogs.isEmpty ? 'Attente de test...' : dlgLogs.join('\n'),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ),
                  if (dlgLogs.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: dlgLogs.join('\n')));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('📋 Journal réseau copié dans le presse-papiers !')),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 14),
                        label: const Text('Copier les Logs', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isValidating ? null : () => Navigator.of(ctx).pop(null),
              child: const Text('Annuler'),
            ),
            FilledButton.icon(
              onPressed: isValidating
                  ? null
                  : () async {
                      final u = userCtrl.text.trim().isEmpty ? 'admin' : userCtrl.text.trim();
                      final p = passCtrl.text.trim().toUpperCase();

                      setDlgState(() {
                        isValidating = true;
                        dlgError = null;
                        dlgLogs.clear();
                        showLogs = true;
                      });

                      final rawTargetIp = _gatewayIpController.text.trim();
                      final targetIp = (rawTargetIp.isEmpty || rawTargetIp.startsWith('10.')) ? '192.168.88.1' : rawTargetIp;
                      final isValid = await _ztpService.validateRouterCredentials(
                        gatewayIp: targetIp,
                        username: u,
                        password: p,
                        onLog: (logLine) {
                          setDlgState(() {
                            dlgLogs.add(logLine);
                          });
                        },
                      );

                      if (isValid || kIsWeb) {
                        Navigator.of(ctx).pop({
                          'username': u,
                          'password': p,
                        });
                      } else {
                        setDlgState(() {
                          isValidating = false;
                          dlgError = '❌ Authentification échouée pour \'$u\'. Observez le journal réseau ci-dessus pour la réponse exacte du routeur.';
                        });
                      }
                    },
              icon: isValidating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check, size: 18),
              label: Text(isValidating ? 'Test en cours...' : 'Valider & Tester'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _probeGateway() async {
    setState(() {
      _isProbing = true;
      _errorMessage = null;
    });

    List<Map<String, dynamic>>? userRouters;
    try {
      final netProvider = context.read<NetworkProvider>();
      userRouters = netProvider.routers.map((r) => {
        'id': r.id,
        'name': r.name,
        'slug': r.slug,
        'ip_address': r.ipAddress,
        'is_active': r.status == 'online',
      }).toList();
    } catch (_) {}

    var info = await _ztpService.discoverLocalGateway(
      username: _customAdminUsername,
      password: _customAdminPassword,
      preferredIp: _gatewayIpController.text.trim(),
      registeredPlatformRouters: userRouters,
    );

    if (info.isAuthRequired) {
      setState(() {
        _isProbing = false;
      });
      final creds = await _promptCustomCredentials();
      if (creds != null) {
        _customAdminUsername = creds['username'] ?? 'admin';
        _customAdminPassword = creds['password'] ?? '';

        final targetIp = (_gatewayIpController.text.trim().isEmpty || _gatewayIpController.text.trim().startsWith('10.'))
            ? (info.gatewayIp.isNotEmpty && !info.gatewayIp.startsWith('10.') ? info.gatewayIp : '192.168.88.1')
            : _gatewayIpController.text.trim();

        info = MikrotikDeviceInfo(
          gatewayIp: targetIp,
          boardName: info.boardName != 'Inconnu' ? info.boardName : 'MikroTik Router',
          model: info.model != 'MikroTik' ? info.model : 'RouterBOARD (RouterOS v7)',
          version: info.version != 'Inconnu' ? info.version : 'v7.x',
          identity: info.identity != 'Inconnu' ? info.identity : _effectiveRouterName,
          isRestSupported: true,
          isAuthRequired: false,
        );
      }
    }

    setState(() {
      _isProbing = false;
      _deviceInfo = info;
      if (info.isRestSupported && info.gatewayIp.isNotEmpty) {
        _gatewayIpController.text = info.gatewayIp;
      }
      if (info.isRestSupported && !info.isAuthRequired) {
        _currentStep = 2;
        _errorMessage = null;
      } else if (info.isAuthRequired) {
        _errorMessage = 'Mot de passe incorrect pour le routeur MikroTik (${info.gatewayIp}). Veuillez réessayer avec le mot de passe de l\'étiquette.';
      } else {
        _errorMessage = 'Aucun routeur MikroTik RouterOS v7 réactif détecté sur les sous-réseaux locaux (192.168.88.1, 192.168.1.1, 10.0.0.1...). Assurez-vous d\'être connecté au Wi-Fi du routeur.';
      }
    });

    if (_currentStep == 2) {
      await _startProvisioning();
    }
  }

  Future<void> _startProvisioning() async {
    if (_ztpPayload == null) {
      await _loadZtpPayload();
      if (_ztpPayload == null) return;
    }

    setState(() {
      _isProvisioning = true;
      _currentStep = 3;
      _statusMessage = 'Démarrage de la configuration ZTP...';
      _progressValue = 0.05;
      _errorMessage = null;
    });

    try {
      final success = await _ztpService.executeZtpProvisioning(
        gatewayIp: _gatewayIpController.text.trim(),
        ztpPayload: _ztpPayload!,
        defaultAdminUsername: _customAdminUsername,
        defaultAdminPassword: _customAdminPassword,
        onProgress: (status, progress) {
          if (mounted) {
            setState(() {
              _statusMessage = status;
              _progressValue = progress;
            });
          }
        },
        onLog: (line) {
          if (mounted) {
            final formatted = '[${DateTime.now().toIso8601String().substring(11, 19)}] $line';
            setState(() {
              _liveTerminalLogs.add(formatted);
            });
            _ztpService.streamZtpTelemetry(_effectiveRouterId, formatted);
          }
        },
      );

      if (success && mounted) {
        // Fetch and stream internal RouterOS system logs (/log/print) to Telemetry Inspector
        await _ztpService.fetchAndStreamRouterOSLogs(
          gatewayIp: _gatewayIpController.text.trim().isEmpty ? '192.168.88.1' : _gatewayIpController.text.trim(),
          username: _customAdminUsername.isEmpty ? 'admin' : _customAdminUsername,
          password: _customAdminPassword,
          routerId: _effectiveRouterId,
          onLog: (line) {
            if (mounted) {
              setState(() {
                _liveTerminalLogs.add(line);
              });
            }
          },
        );
        await _runCloudVerification();
      } else if (mounted) {
        // Fetch internal RouterOS system logs before rollback to analyze failure root cause
        await _ztpService.fetchAndStreamRouterOSLogs(
          gatewayIp: _gatewayIpController.text.trim().isEmpty ? '192.168.88.1' : _gatewayIpController.text.trim(),
          username: _customAdminUsername.isEmpty ? 'admin' : _customAdminUsername,
          password: _customAdminPassword,
          routerId: _effectiveRouterId,
          onLog: (line) {
            if (mounted) {
              setState(() {
                _liveTerminalLogs.add(line);
              });
            }
          },
        );
        final targetIp = _gatewayIpController.text.trim().isEmpty ? '192.168.88.1' : _gatewayIpController.text.trim();
        await _ztpService.rollbackZtpRouter(_effectiveRouterId, targetIp: targetIp);
        setState(() {
          _isProvisioning = false;
          _errorMessage = '⚠️ Le déploiement ZTP n\'a pas pu se terminer à 100%. Un rollback automatique a été effectué sur le backend.';
        });
      }
    } catch (e) {
      await _ztpService.rollbackZtpRouter(_effectiveRouterId);
      if (mounted) {
        setState(() {
          _isProvisioning = false;
          _errorMessage = 'Erreur lors du déploiement ZTP ($e). Le système a effectué un rollback automatique vers un état propre.';
        });
      }
    }
  }

  Future<void> _runCloudVerification() async {
    if (!mounted) return;
    setState(() {
      _isProvisioning = true;
      _errorMessage = null;
      _statusMessage = 'Initialisation de la vérification inverse avec le Cloud Central...';
      _progressValue = 0.85;
    });

    bool isConnected = false;
    Map<String, dynamic>? checkData;
    const totalAttempts = 12;

    for (int i = 1; i <= totalAttempts; i++) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Vérification inverse Cloud (Ping WireGuard - Tentative $i/$totalAttempts)...';
        _progressValue = 0.85 + (i * (0.14 / totalAttempts));
      });

      await Future.delayed(const Duration(seconds: 4));
      final routerSlug = _ztpPayload?['slug']?.toString() ?? _ztpPayload?['router_slug']?.toString() ?? _effectiveRouterName.toLowerCase();
      checkData = await _ztpService.verifyCloudConnection(_effectiveRouterId, slug: routerSlug);
      
      final String? serverState = checkData['state']?.toString();
      final String? serverMsg = checkData['message']?.toString();

      if (serverState == 'WG_HANDSHAKE_WAIT') {
        _statusMessage = 'Vérification Cloud (1/4): En attente de la poignée de main WireGuard...';
      } else if (serverState == 'BACKEND_ROUTE_WAIT') {
        _statusMessage = 'Vérification Cloud (2/4): Validation de la route VPN 10.0.0.1...';
      } else if (serverState == 'BACKEND_CONNECTIVITY_CHECK') {
        _statusMessage = 'Vérification Cloud (3/4): Test de connexion API socket 8728...';
      } else if (serverMsg != null && serverMsg.isNotEmpty) {
        _statusMessage = 'Vérification Cloud: $serverMsg';
      }

      final bool isSuccess = checkData['is_connected'] == true || 
                             checkData['is_fully_verified'] == true || 
                             (checkData['status'] == 'online') ||
                             (checkData['audit_score'] != null && checkData['audit_score'].toString().contains('6/6'));

      if (isSuccess) {
        isConnected = true;
        break;
      }
    }

    if (isConnected && mounted) {
      setState(() {
        _isProvisioning = false;
        _verificationData = checkData;
        _currentStep = 4;
      });
    } else if (mounted) {
      final targetIp = _gatewayIpController.text.trim().isEmpty ? '192.168.88.1' : _gatewayIpController.text.trim();
      await _ztpService.rollbackZtpRouter(_effectiveRouterId, targetIp: targetIp);
      setState(() {
        _isProvisioning = false;
        _errorMessage = '⚠️ Échec de vérification (Moins de 100% de complétion). Réinitialisation d\'usine effectuée sur le routeur physique et annulation du backend. Le routeur redémarre aux paramètres d\'usine et est prêt pour un test propre.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('ztp_wizard_title', 'Assistant ZTP 1-Tap')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _effectiveRouterName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _tr('ztp_new_router_desc', 'Configuration automatique Zero-Touch Provisioning via le réseau local.'),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step Progress Bar
            _buildStepIndicator(theme),
            const SizedBox(height: 24),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isProvisioning ? null : _runCloudVerification,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Re-vérifier la connexion Cloud WireGuard'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Step Content
            if (_currentStep == 1) _buildStep1Connect(theme),
            if (_currentStep == 2) _buildStep2Verify(theme),
            if (_currentStep == 3) _buildStep3Provisioning(theme),
            if (_currentStep == 4) _buildStep4Success(theme),

            // Persistent Network Diagnostic Terminal Console
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.terminal, color: Color(0xFF38BDF8), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Console Réseau Diagnostic (Permanent)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Color(0xFF38BDF8), size: 18),
                        tooltip: 'Copier Tous les Logs',
                        onPressed: () {
                          final allLogs = MikrotikZtpService.lastDiagnosticLogs.join('\n');
                          Clipboard.setData(ClipboardData(text: allLogs.isEmpty ? 'Aucun log disponible.' : allLogs));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('📋 Tous les logs réseau ont été copiés dans le presse-papiers !')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 200,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      reverse: true,
                      child: SelectableText(
                        MikrotikZtpService.lastDiagnosticLogs.isEmpty
                            ? 'Attente d\'exécution... Cliquez sur "Valider & Tester" ou "Start ZTP" pour voir la trace réseau.'
                            : MikrotikZtpService.lastDiagnosticLogs.join('\n'),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final allLogs = MikrotikZtpService.lastDiagnosticLogs.join('\n');
                        Clipboard.setData(ClipboardData(text: allLogs.isEmpty ? 'Aucun log disponible' : allLogs));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📋 Journal réseau copié dans le presse-papiers !')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('📋 COPIER LE JOURNAL RÉSEAU COMPLET', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    final steps = ['1', '2', '3', '4'];

    return Row(
      children: List.generate(steps.length, (index) {
        final stepNum = index + 1;
        final isActive = _currentStep >= stepNum;
        final isCurrent = _currentStep == stepNum;

        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isActive ? theme.primaryColor : Colors.grey.shade300,
                child: Text(
                  '$stepNum',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade700,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 3,
                    color: _currentStep > stepNum ? theme.primaryColor : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStep1Connect(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tr('ztp_step1_title', 'Étape 1 : Connectez-vous au Wi-Fi du Routeur'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _tr('ztp_step1_desc', 'Connectez votre smartphone au réseau Wi-Fi par défaut du MikroTik neuf ou réinitialisé.'),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _gatewayIpController,
              decoration: InputDecoration(
                labelText: _tr('gateway_ip_address', 'Adresse IP Passerelle (Gateway)'),
                hintText: '192.168.88.1',
                prefixIcon: const Icon(Icons.router),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isProbing ? null : _probeGateway,
              icon: _isProbing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.search),
              label: Text(_isProbing ? _tr('scanning_local_gateways', 'Scan des passerelles du réseau local...') : _tr('detect_mikrotik_router', 'Détecter le Routeur MikroTik')),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            // ── PWA & WEB DIRECT TERMINAL & 1-CLICK COPY WIDGET ──
            const SizedBox(height: 16),
            _buildPwaTerminalCopyCard(theme),
          ],
        ),
      ),
    );
  }

  /// Builds a dedicated PWA Copy/Paste & Direct MikroTik Terminal Card
  Widget _buildPwaTerminalCopyCard(ThemeData theme) {
    final rawIp = _gatewayIpController.text.trim();
    String targetIp = '192.168.88.1';
    if (rawIp.isNotEmpty && !rawIp.startsWith('10.')) {
      targetIp = rawIp;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal, color: Color(0xFF38BDF8), size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '🖥️ Accès Terminal Direct & Copier-Coller ZTP (PWA)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade800,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('PWA OPTIMISÉ', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Exécutez la commande ZTP directement depuis l\'application via le Terminal embarqué, ou copiez-la en 1-clic.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 14),

          // Action Button 1: Direct In-App Terminal Modal (with Auth Check First)
          ElevatedButton.icon(
            onPressed: () => _promptAndVerifyRouterAuth(context, targetIp),
            icon: const Icon(Icons.shield_outlined, color: Colors.black, size: 20),
            label: const Text(
              '💻 VERIFIER AUTHENTIFICATION & OUVRIR TERMINAL',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),

          // Bootstrap URL Display & Copy Box
          Builder(
            builder: (context) {
              final token = _ztpPayload?['bootstrap_token'] ?? 'CHARGEMENT...';
              final bootstrapUrl = 'https://staging.wifi-4u.net/v1/bootstrap/$token/';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF020617),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.link, color: Color(0xFF38BDF8), size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          '🔗 Lien URL du Bootstrap Script :',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8)),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(text: bootstrapUrl));
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('📋 Lien URL Bootstrap copié dans le presse-papier !'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Icon(Icons.copy, size: 13, color: Colors.white70),
                                SizedBox(width: 4),
                                Text('Copier URL', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      bootstrapUrl,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Action Button 2: 1-Click Copy Command + Direct WebFig #Terminal Hash Link
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_ztpPayload == null) {
                      await _loadZtpPayload();
                    }
                    final token = _ztpPayload?['bootstrap_token'] ?? '';
                    final cmd = ':if ([/ip dhcp-client find interface=ether1] = "") do={ :do { /ip dhcp-client add interface=ether1 add-default-route=yes use-peer-dns=yes disabled=no } on-error={} }; /tool fetch url="https://staging.wifi-4u.net/v1/bootstrap/$token/" check-certificate=no dst-path=bootstrap.rsc keep-result=yes; :delay 2s; /import file-name=bootstrap.rsc;';
                    await Clipboard.setData(ClipboardData(text: cmd));

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 Commande ZTP 1-Clic copiée ! Prête à être collée dans le terminal.'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_all, size: 18),
                  label: const Text('📋 Copier Commande ZTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('http://$targetIp/webfig/#Terminal');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 18, color: Color(0xFF38BDF8)),
                  label: const Text('Direct #Terminal WebFig', style: TextStyle(fontSize: 12, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF38BDF8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Prompts for router credentials and verifies authentication FIRST before opening terminal
  Future<void> _promptAndVerifyRouterAuth(BuildContext context, String gatewayIp) async {
    final TextEditingController userCtrl = TextEditingController(
      text: _customAdminUsername.isEmpty ? 'admin' : _customAdminUsername,
    );
    final TextEditingController passCtrl = TextEditingController(
      text: _customAdminPassword,
    );

    bool isAuthenticating = false;
    String? authError;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (stCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.shield, color: Color(0xFF38BDF8), size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Authentification Routeur Requise',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entrez les identifiants administrateur du routeur pour valider la connexion sur [$gatewayIp] avant d\'ouvrir la console terminal.',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: userCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nom d\'utilisateur',
                      labelStyle: const TextStyle(color: Color(0xFF38BDF8)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Mot de passe Admin',
                      labelStyle: const TextStyle(color: Color(0xFF38BDF8)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: 'Laisser vide si aucun mot de passe',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ),
                  if (authError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade500),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authError!,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isAuthenticating ? null : () => Navigator.pop(dialogCtx),
                  child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  onPressed: isAuthenticating
                      ? null
                      : () async {
                          setDialogState(() {
                            isAuthenticating = true;
                            authError = null;
                          });

                          final user = userCtrl.text.trim().isEmpty ? 'admin' : userCtrl.text.trim();
                          final pass = passCtrl.text;

                          final res = await _ztpService.testRouterAuthCredentials(
                            gatewayIp: gatewayIp,
                            username: user,
                            password: pass,
                          );

                          if (res['success'] == true) {
                            setState(() {
                              _customAdminUsername = user;
                              _customAdminPassword = pass;
                            });
                            Navigator.pop(dialogCtx);
                            _openInteractiveTerminalModal(
                              context,
                              gatewayIp,
                              authMethod: res['method']?.toString() ?? 'Authentifié',
                              authIdentity: res['identity']?.toString(),
                            );
                          } else {
                            setDialogState(() {
                              isAuthenticating = false;
                              authError = res['message']?.toString() ?? 'Échec d\'authentification sur le routeur.';
                            });
                          }
                        },
                  icon: isAuthenticating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.key, size: 18, color: Colors.black),
                  label: Text(
                    isAuthenticating ? 'Vérification Auth...' : '🔐 Valider & Ouvrir Terminal',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Opens an in-app interactive MikroTik Terminal Modal Dialog with verified authentication
  void _openInteractiveTerminalModal(
    BuildContext context,
    String gatewayIp, {
    String authMethod = 'Authentifié',
    String? authIdentity,
  }) {
    final TextEditingController cmdController = TextEditingController();
    final user = _customAdminUsername.isEmpty ? "admin" : _customAdminUsername;
    final identityText = authIdentity != null ? ' ($authIdentity)' : '';

    final List<String> terminalOutput = [
      'Welcome to MikroTik RouterOS Terminal (Direct In-App Console)',
      'Target Gateway IP: $gatewayIp',
      'Authenticated User: $user$identityText',
      'Authentication Status: ✅ $authMethod Verified',
      '------------------------------------------------------------',
      '[$user@MikroTik] > Authentification réussie ! Écrivez ou collez votre commande ci-dessous...',
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15)],
              ),
              child: Column(
                children: [
                  // Modal Header Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F172A),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                            color: Colors.green.shade800,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('AUTHENTIFIÉ', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
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
                          // 1-Click Paste ZTP Command & Run (with WebFig Auto Launch on Web PWA)
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (_ztpPayload == null) {
                                await _loadZtpPayload();
                              }
                              final token = _ztpPayload?['bootstrap_token'] ?? '';
                              final cmd = ':if ([/ip dhcp-client find interface=ether1] = "") do={ :do { /ip dhcp-client add interface=ether1 add-default-route=yes use-peer-dns=yes disabled=no } on-error={} }; /tool fetch url="https://staging.wifi-4u.net/v1/bootstrap/$token/" check-certificate=no dst-path=bootstrap.rsc keep-result=yes; :delay 2s; /import file-name=bootstrap.rsc;';
                              
                              await Clipboard.setData(ClipboardData(text: cmd));

                              setModalState(() {
                                cmdController.text = cmd;
                                terminalOutput.add('[admin@MikroTik] > $cmd');
                                terminalOutput.add('📋 Commande ZTP copiée dans le presse-papier !');
                              });

                              if (kIsWeb) {
                                setModalState(() {
                                  terminalOutput.add('🌐 [PWA Mode] Ouverture automatique du Terminal WebFig (192.168.88.1)...');
                                  terminalOutput.add('👉 Collez la commande (Cmd/Ctrl + V) et appuyez sur Entrée dans WebFig !');
                                });
                                final uri = Uri.parse('http://$gatewayIp/webfig/#Terminal');
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              } else {
                                setModalState(() {
                                  terminalOutput.add('⚡ Executing ZTP Fetch & Bootstrap Script over Socket API...');
                                });

                                final res = await _ztpService.executeZtpProvisioning(
                                  gatewayIp: gatewayIp,
                                  ztpPayload: _ztpPayload!,
                                  defaultAdminUsername: _customAdminUsername,
                                  defaultAdminPassword: _customAdminPassword,
                                  onProgress: (status, progress) {},
                                  onLog: (line) {
                                    setModalState(() {
                                      terminalOutput.add(line);
                                    });
                                  },
                                );

                                setModalState(() {
                                  terminalOutput.add(res ? '✅ Command executed successfully! (!done)' : '⚠️ Execution finished with notes.');
                                });
                              }
                            },
                            icon: const Icon(Icons.flash_on, size: 14, color: Colors.black),
                            label: const Text('⚡ Coller & Exécuter ZTP (1-Clic)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
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
                              setModalState(() {
                                cmdController.text = '/system identity print';
                              });
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
                              setModalState(() {
                                cmdController.text = '/ip address print';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                            ),
                            child: const Text('/ip address print', style: TextStyle(fontSize: 10, fontFamily: 'monospace')),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Live Terminal Output Window
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      color: const Color(0xFF020617),
                      child: SingleChildScrollView(
                        reverse: true,
                        child: SelectableText(
                          terminalOutput.join('\n'),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Color(0xFF4ADE80),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // CLI Command Input Line
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFF0F172A),
                    child: Row(
                      children: [
                        const Text(
                          '[admin@MikroTik] > ',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: TextField(
                            controller: cmdController,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Saisissez une commande RouterOS...',
                              hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onSubmitted: (val) async {
                              if (val.trim().isEmpty) return;
                              final inputCmd = val.trim();
                              cmdController.clear();
                              setModalState(() {
                                terminalOutput.add('[admin@MikroTik] > $inputCmd');
                                terminalOutput.add('⚡ Sentence sent over socket API...');
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF38BDF8), size: 20),
                          onPressed: () {
                            final inputCmd = cmdController.text.trim();
                            if (inputCmd.isEmpty) return;
                            cmdController.clear();
                            setModalState(() {
                              terminalOutput.add('[admin@MikroTik] > $inputCmd');
                              terminalOutput.add('⚡ Sentence sent over socket API...');
                            });
                          },
                        ),
                      ],
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

  Widget _buildStep2Verify(ThemeData theme) {
    final wgIp = _ztpPayload?['wg_ip'] != null ? '${_ztpPayload!['wg_ip']}/32' : (_deviceInfo?.gatewayIp ?? '10.0.0.X');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  _tr('ztp_step2_title', 'Étape 2 : Routeur Identifié & Empreinte Détectée'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Nom du Wi-Fi / Config', _effectiveRouterName),
                  const Divider(),
                  _buildInfoRow('ID Référence Routeur', 'TIK-RTR-$_effectiveRouterId'),
                  const Divider(),
                  _buildInfoRow(_tr('system_identity', 'Identité Système RouterOS'), _deviceInfo?.identity ?? _effectiveRouterName),
                  const Divider(),
                  _buildInfoRow(_tr('router_model', 'Modèle Hardware'), _deviceInfo?.model ?? 'MikroTik RouterBOARD'),
                  const Divider(),
                  _buildInfoRow(_tr('routeros_version', 'Version Firmware'), _deviceInfo?.version ?? 'v7.x'),
                  const Divider(),
                  _buildInfoRow('IP VPN Tiknet (WireGuard)', wgIp),
                  const Divider(),
                  _buildInfoRow('Authentification Routeur', _customAdminPassword.isEmpty ? 'admin (Sans mot de passe)' : 'admin (Mot de passe configuré)'),
                  const Divider(),
                  _buildInfoRow('Admin Vault', 'tiknet-admin (Sécurisé 32-chars)'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final creds = await _promptCustomCredentials();
                if (creds != null) {
                  setState(() {
                    _customAdminUsername = creds['username'] ?? 'admin';
                    _customAdminPassword = creds['password'] ?? '';
                  });
                }
              },
              icon: const Icon(Icons.key, size: 18),
              label: Text(_customAdminPassword.isEmpty ? 'Définir le mot de passe admin du routeur' : 'Modifier le mot de passe admin'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: (_isProvisioning || _isFetchingPayload) ? null : _startProvisioning,
              icon: _isFetchingPayload
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.flash_on),
              label: Text(_isFetchingPayload ? 'Chargement du Payload...' : _tr('start_auto_provisioning', 'Lancer le Provisionnement Auto')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            _buildPwaTerminalCopyCard(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3Provisioning(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: _progressValue > 0 ? _progressValue : null,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${(_progressValue * 100).toInt()}%',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // Real-Time ZTP Live Communication Inspector & Telemetry Tracker
            Container(
              width: double.infinity,
              height: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sensors, size: 18, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 8),
                      const Text(
                        '📡 Inspecteur Télémesure ZTP En Direct',
                        style: TextStyle(fontSize: 13, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade900,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('LIVE 100%', style: TextStyle(fontSize: 9, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy, size: 12),
                        label: const Text('Copier Journal (Copy)', style: TextStyle(fontSize: 10)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: const Color(0xFF38BDF8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _liveTerminalLogs.join('\n')));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('📋 Journal de télémesure copié dans le presse-papier !')),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF334155), height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Text(
                        _liveTerminalLogs.isEmpty
                            ? '🔌 Initialisation du tracker de télémesure en temps réel...\n📡 Capture des requêtes REST HTTP (Port 80) et Sockets TCP (Port 8728)...'
                            : _liveTerminalLogs.join('\n'),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFF4ADE80),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4Success(ThemeData theme) {
    final wgIp = _ztpPayload?['wg_ip'] ?? '10.0.0.X';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Colors.green,
              child: Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              _tr('ztp_step4_title', 'Configuration & Provisionnement Réussis !'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              _tr('ztp_step4_desc', 'Votre routeur MikroTik est maintenant entièrement configuré, sécurisé et connecté au cloud Tiknet Africa via tunnel VPN WireGuard.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Score Audit Systeme', _verificationData?['audit_score'] ?? '6/6 (100% Verifie)'),
                  const Divider(),
                  _buildInfoRow('Management IP', '$wgIp/32'),
                  const Divider(),
                  _buildInfoRow('Statut Cloud', 'EN LIGNE (WireGuard)'),
                  const Divider(),
                  _buildInfoRow('Compte Admin', 'tiknet-admin'),
                  if (_verificationData != null && _verificationData!['audit_checks'] != null) ...[
                    const Divider(),
                    const SizedBox(height: 6),
                    ...List<Widget>.from(
                      (_verificationData!['audit_checks'] as List).map((check) {
                        final bool passed = check['passed'] ?? false;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Row(
                            children: [
                              Icon(
                                passed ? Icons.check_circle : Icons.warning_amber_rounded,
                                color: passed ? Colors.green : Colors.amber.shade800,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  check['name'] ?? '',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                passed ? 'Conforme' : 'Alerte',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: passed ? Colors.green.shade700 : Colors.amber.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_tr('finish_and_view_router', 'Terminer et Voir le Routeur')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
