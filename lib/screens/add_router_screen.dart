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

  /// Flatten the server response into a list of human-readable command strings.
  /// The API may return commands as a list, a map of steps, or raw text.
  List<_CommandEntry> _parseCommands(Map<String, dynamic> response) {
    final List<_CommandEntry> entries = [];

    void addFromValue(dynamic value, String label) {
      if (value is List) {
        for (int i = 0; i < value.length; i++) {
          entries.add(_CommandEntry(
            index: entries.length + 1,
            label: value.length > 1 ? '$label [${i + 1}]' : label,
            command: value[i].toString(),
          ));
        }
      } else if (value is Map) {
        value.forEach((k, v) {
          addFromValue(v, '$label › $k');
        });
      } else if (value != null && value.toString().isNotEmpty) {
        entries.add(_CommandEntry(
          index: entries.length + 1,
          label: label,
          command: value.toString(),
        ));
      }
    }

    // Look for known command keys first
    const commandKeys = [
      'commands',
      'mikrotik_commands',
      'scripts',
      'steps',
      'config',
      'configuration',
      'setup_commands',
    ];

    bool foundCommandKey = false;
    for (final key in commandKeys) {
      if (response.containsKey(key)) {
        foundCommandKey = true;
        addFromValue(response[key], key);
      }
    }

    // If no known key found, flatten the entire response
    if (!foundCommandKey) {
      response.forEach((key, value) {
        if (value is List || value is Map) {
          addFromValue(value, key);
        } else if (value != null && value.toString().isNotEmpty) {
          entries.add(_CommandEntry(
            index: entries.length + 1,
            label: key,
            command: value.toString(),
          ));
        }
      });
    }

    return entries;
  }

  Widget _buildResponsePanel(ColorScheme colorScheme) {
    if (_serverResponse == null) return const SizedBox.shrink();

    final commands = _parseCommands(_serverResponse!);
    final rawJson =
        const JsonEncoder.withIndent('  ').convert(_serverResponse);

    return FadeTransition(
      opacity: _responseAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 28),

          // ── Header bar ──────────────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() => _responseExpanded = !_responseExpanded);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade800,
                    Colors.teal.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.terminal, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Server Response — MikroTik Commands',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  if (commands.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${commands.length} cmd${commands.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    _responseExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // ── Collapsible body ─────────────────────────────────────────
          if (_responseExpanded) ...[
            const SizedBox(height: 2),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(
                  color: Colors.green.shade800.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Commands list
                  if (commands.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                      child: Text(
                        '// Execute the following commands on your MikroTik:',
                        style: TextStyle(
                          color: Colors.green.shade400,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    ...commands.map((cmd) => _buildCommandTile(cmd)),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        '// No commands found — raw response shown below.',
                        style: TextStyle(
                          color: Colors.amber.shade400,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],

                  // Divider + raw JSON toggle
                  const Divider(color: Color(0xFF30363D), height: 1),
                  _buildRawJsonSection(rawJson, colorScheme),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommandTile(_CommandEntry cmd) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: ListTile(
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green.shade900,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${cmd.index}',
              style: TextStyle(
                color: Colors.green.shade300,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          cmd.label,
          style: TextStyle(
            color: Colors.blue.shade300,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SelectableText(
            cmd.command,
            style: const TextStyle(
              color: Color(0xFFE6EDF3),
              fontSize: 12,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 16),
          color: Colors.grey.shade500,
          tooltip: 'Copy command',
          onPressed: () => _copyToClipboard(cmd.command),
        ),
      ),
    );
  }

  Widget _buildRawJsonSection(String rawJson, ColorScheme colorScheme) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: EdgeInsets.zero,
        iconColor: Colors.grey.shade500,
        collapsedIconColor: Colors.grey.shade600,
        title: Text(
          'Raw JSON Response',
          style: TextStyle(
            color: Colors.grey.shade400,
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
            padding: const EdgeInsets.all(14),
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

/// Simple data class for a parsed command entry.
class _CommandEntry {
  final int index;
  final String label;
  final String command;

  const _CommandEntry({
    required this.index,
    required this.label,
    required this.command,
  });
}
