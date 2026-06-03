import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/router_configuration_model.dart';
import '../providers/split/network_provider.dart';
import 'package:provider/provider.dart';

class AddRouterScreen extends StatefulWidget {
  const AddRouterScreen({super.key});

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

  // Constants — not shown to user, always sent to API
  static const int _apiPort = 8728;
  static const int _coaPort = 3799;

  bool _passwordVisible = false;
  bool _radiusSecretVisible = false;
  RouterConfigurationModel? _existingConfig;

  // Server response state
  Map<String, dynamic>? _serverResponse;
  bool _responseExpanded = true;
  late AnimationController _responseAnimController;
  late Animation<double> _responseAnimation;

  @override
  void initState() {
    super.initState();
    _responseAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _responseAnimation = CurvedAnimation(
      parent: _responseAnimController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is RouterConfigurationModel) {
        setState(() {
          _existingConfig = args;
          _nameController.text = args.name;
          _passwordController.text = args.password ?? '';
          _radiusSecretController.text = args.radiusSecret ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _radiusSecretController.dispose();
    _scrollController.dispose();
    _responseAnimController.dispose();
    super.dispose();
  }

  Future<void> _saveConfiguration() async {
    if (_formKey.currentState!.validate()) {
      final networkProvider = context.read<NetworkProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final isEdit = _existingConfig != null;

      final data = {
        'name': _nameController.text.trim(),
        'password': _passwordController.text,
        'secret': _radiusSecretController.text.trim(),
        'api_port': _apiPort,
        'coa_port': _coaPort,
        'is_active': true,
      };

      try {
        Map<String, dynamic>? response;
        if (isEdit) {
          response =
              await networkProvider.updateRouter(_existingConfig!.slug, data);
        } else {
          response = await networkProvider.addRouter(data);
        }

        if (mounted) {
          setState(() {
            _serverResponse = response;
            _responseExpanded = true;
          });
          _responseAnimController.forward(from: 0);

          // Scroll to bottom to reveal the response panel
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
              content: Text(
                isEdit
                    ? 'router_config_updated'.tr()
                    : 'router_config_saved'.tr(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('error_occurred'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: Colors.blueGrey.shade700,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  List<String> _extractCommands(Map<String, dynamic> response) {
    const keys = ['commands', 'mikrotik_commands', 'scripts', 'steps'];
    for (var key in keys) {
      if (response.containsKey(key) && response[key] is List) {
        return (response[key] as List).map((e) => e.toString()).toList();
      }
    }
    return [];
  }

  Widget _buildInfoCard(String title, List<Widget> children, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1))),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 20,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value, {Color? valueColor}) {
    // Determine roughly half width minus padding (mobile layout first)
    final width = (MediaQuery.of(context).size.width - 40 - 32 - 16) / 2;
    return SizedBox(
      width: width > 120 ? width : null, // fallback if width too small
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : 'N/A',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsePanel(ColorScheme colorScheme) {
    if (_serverResponse == null) return const SizedBox.shrink();

    final commands = _extractCommands(_serverResponse!);
    final rawJson = const JsonEncoder.withIndent('  ').convert(_serverResponse);

    // Extract General Info
    final name = _serverResponse!['name']?.toString() ?? _nameController.text;
    final ref = _serverResponse!['id']?.toString() ?? _serverResponse!['slug']?.toString() ?? '#N/A';
    final partner = _serverResponse!['partner']?.toString() ?? _serverResponse!['username']?.toString() ?? 'Admin';
    final statusRaw = _serverResponse!['status']?.toString();
    final isActive = _serverResponse!['is_active'] == true || statusRaw?.toLowerCase() == 'online' || statusRaw?.toLowerCase() == 'actif';
    final statusText = isActive ? 'Actif' : (statusRaw ?? 'Pending');
    final dnsName = _serverResponse!['dns_name']?.toString() ?? '$name.net';
    final ipAddress = _serverResponse!['ip_address']?.toString() ?? _serverResponse!['wireguard_ip']?.toString() ?? '10.0.0.X';

    // Technical Info
    final techUser = _serverResponse!['username']?.toString() ?? 'tiknet-admin';
    final techPass = _passwordController.text.isNotEmpty ? _passwordController.text : '********';
    final techSecret = _radiusSecretController.text.isNotEmpty ? _radiusSecretController.text : '********';

    return FadeTransition(
      opacity: _responseAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          
          Text(
            'Routeur : $name',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // 1. Informations Générales
          _buildInfoCard(
            'Informations Générales',
            [
              _buildInfoField('Nom du routeur', name),
              _buildInfoField('Référence', '#$ref'),
              _buildInfoField('Partenaire', partner),
              _buildInfoField('Statut', statusText, valueColor: isActive ? Colors.green.shade600 : Colors.amber.shade700),
              _buildInfoField('Dns Name', dnsName),
              _buildInfoField('WireGuard IP', ipAddress, valueColor: Colors.teal.shade600),
            ],
            colorScheme,
          ),

          // 2. Commande Bootstrap
          if (commands.isNotEmpty)
            _buildInfoCard(
              'Commande Bootstrap',
              [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _copyToClipboard(commands.join('\n')),
                        icon: const Icon(Icons.copy, size: 14),
                        label: const Text('Copier la commande', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF30363D)),
                        ),
                        child: SelectableText(
                          commands.join('\n'),
                          style: const TextStyle(
                            color: Color(0xFFE6EDF3),
                            fontFamily: 'monospace',
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Copiez cette commande et exécutez-la sur votre routeur MikroTik pour lancer le bootstrap.',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              colorScheme,
            ),

          // 3. Informations Techniques
          _buildInfoCard(
            'Informations Techniques',
            [
              _buildInfoField('Username', techUser),
              _buildInfoField('Mot de passe', techPass, valueColor: Colors.blue.shade600),
              Container(
                width: double.infinity, // Full width for Secret to match design
                margin: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Radius Secret',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: SelectableText(
                        techSecret,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            colorScheme,
          ),

          // Raw JSON (Fallback)
          const SizedBox(height: 16),
          _buildRawJsonSection(rawJson, colorScheme),
        ],
      ),
    );
  }

  Widget _buildRawJsonSection(String rawJson, ColorScheme colorScheme) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        iconColor: Colors.grey.shade500,
        collapsedIconColor: Colors.grey.shade600,
        title: Text(
          'Raw JSON Response (Debug)',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 15),
              color: Colors.grey.shade500,
              tooltip: 'Copy JSON',
              onPressed: () => _copyToClipboard(rawJson),
            ),
            const Icon(Icons.expand_more, size: 18),
          ],
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              rawJson,
              style: const TextStyle(
                color: Color(0xFFE6EDF3),
                fontSize: 11,
                fontFamily: 'monospace',
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existingConfig != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'edit_router'.tr() : 'add_new_router'.tr()),
        actions: [
          if (_serverResponse != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Clear response',
              onPressed: () {
                setState(() {
                  _serverResponse = null;
                });
                _responseAnimController.reset();
              },
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
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: colorScheme.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'router_config_info'.tr(),
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Wifi Name
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'wifi_name'.tr(),
                        hintText: 'wifi_name_hint'.tr(),
                        prefixIcon: const Icon(Icons.wifi),
                        border: const OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'enter_wifi_name'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // MikroTik Password
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'mikrotik_password'.tr(),
                        hintText: 'mikrotik_password_hint'.tr(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_passwordVisible,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_mikrotik_password'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Radius Secret
                    TextFormField(
                      controller: _radiusSecretController,
                      decoration: InputDecoration(
                        labelText: 'radius_secret'.tr(),
                        hintText: 'radius_secret_hint'.tr(),
                        prefixIcon: const Icon(Icons.key_outlined),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _radiusSecretVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _radiusSecretVisible = !_radiusSecretVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_radiusSecretVisible,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _saveConfiguration(),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'enter_radius_secret'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Constant values info (read-only display)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'default_settings'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.settings_ethernet,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                'API Port: $_apiPort  •  CoA Port: $_coaPort',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Server Response Panel ──────────────────────────────
                    _buildResponsePanel(colorScheme),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SafeArea(
                child: Consumer<NetworkProvider>(
                  builder: (context, provider, _) {
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: provider.isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('cancel'.tr()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed:
                                provider.isLoading ? null : _saveConfiguration,
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_serverResponse != null
                                    ? 'Resubmit'
                                    : 'save_configuration'.tr()),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
