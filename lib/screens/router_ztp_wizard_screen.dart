import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

  String _statusMessage = '';
  double _progressValue = 0.0;
  String? _errorMessage;

  int _effectiveRouterId = 0;
  String _effectiveRouterName = 'Nouveau Routeur';

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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ce routeur est protégé (boîtier déjà configuré ou mot de passe inscrit sur l\'étiquette au dos du routeur). Veuillez le saisir ci-dessous pour continuer.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: userCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passCtrl,
                obscureText: passObscured,
                decoration: InputDecoration(
                  labelText: 'Mot de passe actuel (Sticker / Admin)',
                  prefixIcon: const Icon(Icons.key_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(passObscured ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setDlgState(() => passObscured = !passObscured),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Annuler'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop({
                  'username': userCtrl.text.trim().isEmpty ? 'admin' : userCtrl.text.trim(),
                  'password': passCtrl.text,
                });
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Valider & Continuer'),
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

        setState(() {
          _isProbing = true;
        });

        info = await _ztpService.discoverLocalGateway(
          username: _customAdminUsername,
          password: _customAdminPassword,
          preferredIp: _gatewayIpController.text.trim(),
          registeredPlatformRouters: userRouters,
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
      } else if (info.isAuthRequired) {
        _errorMessage = 'Mot de passe incorrect pour le routeur MikroTik (${info.gatewayIp}). Veuillez réessayer avec le mot de passe de l\'étiquette.';
      } else {
        _errorMessage = 'Aucun routeur MikroTik RouterOS v7 réactif détecté sur les sous-réseaux locaux (192.168.88.1, 192.168.1.1, 10.0.0.1...). Assurez-vous d\'être connecté au Wi-Fi du routeur.';
      }
    });
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
      );

      if (success && mounted) {
        setState(() {
          _isProvisioning = false;
          _currentStep = 4;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProvisioning = false;
          _errorMessage = 'Erreur lors du déploiement ZTP : $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('ztp_wizard_title'.tr()),
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
                    'ztp_new_router_desc'.tr(),
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
                child: Row(
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
              ),
              const SizedBox(height: 20),
            ],

            // Step Content
            if (_currentStep == 1) _buildStep1Connect(theme),
            if (_currentStep == 2) _buildStep2Verify(theme),
            if (_currentStep == 3) _buildStep3Provisioning(theme),
            if (_currentStep == 4) _buildStep4Success(theme),
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
              'ztp_step1_title'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'ztp_step1_desc'.tr(),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _gatewayIpController,
              decoration: InputDecoration(
                labelText: 'gateway_ip_address'.tr(),
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
              label: Text(_isProbing ? 'scanning_local_gateways'.tr() : 'detect_mikrotik_router'.tr()),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2Verify(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ztp_step2_title'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('router_model'.tr(), _deviceInfo?.model ?? 'MikroTik'),
                  const Divider(),
                  _buildInfoRow('system_identity'.tr(), _deviceInfo?.identity ?? 'MikroTik'),
                  const Divider(),
                  _buildInfoRow('routeros_version'.tr(), _deviceInfo?.version ?? '7.x'),
                  const Divider(),
                  _buildInfoRow('gateway_ip'.tr(), _deviceInfo?.gatewayIp ?? '192.168.88.1'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: (_isProvisioning || _isFetchingPayload) ? null : _startProvisioning,
              icon: const Icon(Icons.flash_on),
              label: Text('start_auto_provisioning'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
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
              'ztp_step4_title'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              'ztp_step4_desc'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Management IP', '$wgIp/32'),
                  const Divider(),
                  _buildInfoRow('Statut', 'EN LIGNE (WireGuard)'),
                  const Divider(),
                  _buildInfoRow('Admin User', 'tiknet-admin'),
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
              child: Text('finish_and_view_router'.tr()),
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
