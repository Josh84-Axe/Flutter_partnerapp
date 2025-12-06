›<import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';

class CreateRoleScreen extends StatefulWidget {
  final Map<String, dynamic>? roleData;

  const CreateRoleScreen({super.key, this.roleData});

  @override
  State<CreateRoleScreen> createState() => _CreateRoleScreenState();
}

class _CreateRoleScreenState extends State<CreateRoleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  final Set<int> _selectedPermissionIds = {};
  List<dynamic> _availablePermissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.roleData?['name'] ?? '');
    _loadPermissions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissions() async {
    try {
      // Add a timeout to prevent infinite loading
      final permissions = await context.read<AppState>().fetchPermissions()
          .timeout(const Duration(seconds: 10));
      
      if (mounted) {
        setState(() {
          _availablePermissions = permissions;
          _isLoading = false;
          
          // If editing, pre-select permissions
          if (widget.roleData != null && widget.roleData!['permissions'] != null) {
            final currentPerms = widget.roleData!['permissions'] as List;
            for (var perm in currentPerms) {
              if (perm is int) {
                _selectedPermissionIds.add(perm);
              } else if (perm is Map && perm['id'] != null) {
                _selectedPermissionIds.add(perm['id']);
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading permissions: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadPermissions,
            ),
          ),
        );
      }
    }
  }

  void _saveRole() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final data = {
      'name': _nameController.text,
      'permissions': _selectedPermissionIds.toList(),
    };

    if (widget.roleData != null) {
      final slug = widget.roleData!['slug'] ?? widget.roleData!['id'];
      context.read<AppState>().updateRole(slug, data);
    } else {
      context.read<AppState>().createRole(data);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.roleData != null ? 'role_updated'.tr() : 'role_created'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roleData != null ? 'edit_role'.tr() : 'create_new_role'.tr()),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'role_name'.tr(),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'please_enter_role_name'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'permissions'.tr(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (_availablePermissions.isEmpty)
                            Text('no_permissions_available'.tr())
                          else
                            ..._availablePermissions.map((perm) {
                              final id = perm['id'] as int;
                              final name = perm['name'] as String;
                              final codename = perm['codename'] as String;
                              
                              return CheckboxListTile(
                                title: Text(name),
                                subtitle: Text(codename),
                                value: _selectedPermissionIds.contains(id),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedPermissionIds.add(id);
                                    } else {
                                      _selectedPermissionIds.remove(id);
                                    }
                                  });
                                },
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('cancel'.tr()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _saveRole,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text('save_role'.tr()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
å åå*cascade08
å‹ ‹ﬁ*cascade08
ﬁﬂ ﬂ‡*cascade08
‡· ·‰*cascade08
‰Â ÂÊ*cascade08
ÊÁ ÁÍ*cascade08
ÍÎ ÎÌ*cascade08
ÌÒ ÒÛ*cascade08
Û˙ ˙¸*cascade08
¸˛ ˛ˇ*cascade08
ˇÇ ÇÑ*cascade08
ÑÜ Üá*cascade08
áä äí*cascade08
íî îò*cascade08
òö öõ*cascade08
õù ùû*cascade08
û† †¶*cascade08
¶® ®´*cascade08
´¨ ¨Æ*cascade08
Æ≤ ≤¥*cascade08
¥µ µª*cascade08
ªº ºΩ*cascade08
Ωø ø¿*cascade08
¿¡ ¡¬*cascade08
¬√ √ƒ*cascade08
ƒ∆ ∆…*cascade08
…   Œ*cascade08
Œœ œ“*cascade08
“” ”‘*cascade08
‘÷ ÷ÿ*cascade08
ÿŸ Ÿ‹*cascade08
‹› ›·*cascade08
·‚ ‚„*cascade08
„Á ÁÏ*cascade08
ÏÌ Ìı*cascade08
ıˆ ˆ˜*cascade08
˜¯ ¯ç*cascade08
çé éè*cascade08
èì ìï*cascade08
ïñ ñó*cascade08
óò òô*cascade08
ôö öù*cascade08
ùû û†*cascade08
†° °¢*cascade08
¢£ £¶*cascade08
¶ß ß≠*cascade08
≠Æ Ææ*cascade08
æ¬ ¬«*cascade08
«» »–*cascade08
–“ “‘*cascade08
‘’ ’Ÿ*cascade08
Ÿ‰ ‰Á*cascade08
ÁË ËÈ*cascade08
ÈÍ ÍÔ*cascade08
ÔÒ ÒÙ*cascade08
Ùı ı¯*cascade08
¯˙ ˙¸*cascade08
¸˝ ˝ˇ*cascade08
ˇÄ ÄÅ*cascade08
ÅÇ ÇÉ*cascade08
ÉÑ Ñä*cascade08
äã ãç*cascade08
çé éí*cascade08
íì ìö*cascade08
öû û¢*cascade08
¢£ £•*cascade08
•¶ ¶®*cascade08
®© ©™*cascade08
™≠ ≠Ø*cascade08
Ø≤ ≤≥*cascade08
≥¥ ¥µ*cascade08
µª ªº*cascade08
ºΩ Ω¡*cascade08
¡» » *cascade08
 Ã ÃÕ*cascade08
Õœ œ—*cascade08
—“ “‘*cascade08
‘’ ’÷*cascade08
÷◊ ◊⁄*cascade08
⁄‡ ‡·*cascade08
·‚ ‚„*cascade08
„Â ÂÁ*cascade08
ÁË ËÏ*cascade08
ÏÌ ÌÓ*cascade08
ÓÒ ÒÚ*cascade08
Ú˝ ˝ˇ*cascade08
ˇÉ ÉÖ*cascade08
Öá áì*cascade08
ìï ïó*cascade08
óô ôû*cascade08
û¶ ¶ß*cascade08
ß© ©™*cascade08
™´ ´≠*cascade08
≠Ø Ø∞*cascade08
∞± ±≥*cascade08
≥¥ ¥∏*cascade08
∏π πæ*cascade08
æø ø¡*cascade08
¡≈ ≈∆*cascade08
∆Õ Õœ*cascade08
œ– –“*cascade08
“” ”÷*cascade08
÷Ÿ Ÿ⁄*cascade08
⁄ﬁ ﬁﬂ*cascade08
ﬂ„ „‰*cascade08
‰Í ÍÛ*cascade08
Û˜ ˜˚*cascade08
˚¸ ¸Ñ*cascade08
ÑÜ Üá*cascade08
áç çí*cascade08
íñ ñö*cascade08
öú ú§*cascade08
§• •ß*cascade08
ß≠ ≠Ø*cascade08
Ø∞ ∞≥*cascade08
≥µ µ∑*cascade08
∑º ºΩ*cascade08
Ω¡ ¡∆*cascade08
∆» »Õ*cascade08
ÕŒ Œ–*cascade08
–“ “‘*cascade08
‘’ ’◊*cascade08
◊ÿ ÿ€*cascade08
€› ›·*cascade08
·‰ ‰Â*cascade08
ÂÊ ÊÔ*cascade08
Ôı ı¯*cascade08
¯˘ ˘¸*cascade08
¸Ç ÇÑ*cascade08
ÑÖ Öà*cascade08
àâ âä*cascade08
äã ãè*cascade08
èê êî*cascade08
îï ïó*cascade08
óô ôö*cascade08
öõ õ†*cascade08
†° °¢*cascade08
¢£ £§*cascade08
§¶ ¶ß*cascade08
ß´ ´Æ*cascade08
Æ∂ ∂ª*cascade08
ªº º«*cascade08
«» »…*cascade08
…Ã Ãœ*cascade08
œ“ “ÿ*cascade08
ÿŸ Ÿ‚*cascade08
‚„ „Ë*cascade08
ËÈ ÈÎ*cascade08
ÎÏ ÏÌ*cascade08
ÌÓ ÓÔ*cascade08
Ô ¯*cascade08
¯á	 á	ï	*cascade08
ï	ñ	 ñ	ó	*cascade08
ó	ö	 ö	õ	*cascade08
õ	ù	 ù	ü	*cascade08
ü	§	 §	•	*cascade08
•	¶	 ¶	ß	*cascade08
ß	®	 ®	©	*cascade08
©	™	 ™	´	*cascade08
´	¨	 ¨	≠	*cascade08
≠	Ω	 Ω	ø	*cascade08
ø	¿	 ¿	…	*cascade08
…	 	  	À	*cascade08
À	’	 ’	ﬂ	*cascade08
ﬂ	‡	 ‡	‚	*cascade08
‚	Ó	 Ó	Ú	*cascade08
Ú	ı	 ı	˜	*cascade08
˜	¯	 ¯	˙	*cascade08
˙	˚	 ˚	É
*cascade08
É
Ñ
 Ñ
Ö
*cascade08
Ö
Ü
 Ü
ç
*cascade08
ç
è
 è
í
*cascade08
í
û
 û
®
*cascade08
®
©
 ©
™
*cascade08
™
´
 ´
≠
*cascade08
≠
Æ
 Æ
Ø
*cascade08
Ø
∞
 ∞
±
*cascade08
±
…
 …
À
*cascade08
À
Ã
 Ã
Œ
*cascade08
Œ
œ
 œ
—
*cascade08
—
’
 ’
⁄
*cascade08
⁄
€
 €
·
*cascade08
·
‚
 ‚
Î
*cascade08
Î
Ì
 Ì
Ó
*cascade08
Ó
˙
 ˙
¸
*cascade08
¸
˛
 ˛
ˇ
*cascade08
ˇ
Ä ÄÅ*cascade08
ÅÇ ÇÉ*cascade08
ÉÑ ÑÖ*cascade08
Öá áà*cascade08
àâ âã*cascade08
ãå åç*cascade08
çé éê*cascade08
êë ëï*cascade08
ïñ ñò*cascade08
òô ôû*cascade08
ûü ü¢*cascade08
¢§ §¶*cascade08
¶ß ß¨*cascade08
¨≠ ≠≥*cascade08
≥∂ ∂∏*cascade08
∏π πª*cascade08
ªº º¡*cascade08
¡¬ ¬≈*cascade08
≈— —“*cascade08
“‘ ‘÷*cascade08
÷ÿ ÿ‹*cascade08
‹ﬁ ﬁÂ*cascade08
ÂÊ ÊË*cascade08
ËÌ Ì*cascade08
Ò ÒÛ*cascade08
ÛÙ Ù˙*cascade08
˙˚ ˚¸*cascade08
¸˝ ˝ˇ*cascade08
ˇÄ ÄÖ*cascade08
ÖÜ Üà*cascade08
àâ âé*cascade08
éú úü*cascade08
ü† †§*cascade08
§• •©*cascade08
©¨ ¨≠*cascade08
≠Æ Æ±*cascade08
±≤ ≤≥*cascade08
≥¥ ¥∂*cascade08
∂∑ ∑π*cascade08
π∫ ∫º*cascade08
ºÃ ÃŒ*cascade08
Œœ œ‘*cascade08
‘’ ’◊*cascade08
◊ÿ ÿ€*cascade08
€› ›ﬁ*cascade08
ﬁ Ò*cascade08
ÒÚ Úˆ*cascade08
ˆ˘ ˘Å*cascade08
ÅÇ Çä*cascade08
äã ãè*cascade08
èê êë*cascade08
ë° °¢*cascade08
¢£ £ß*cascade08
ß® ®™*cascade08
™´ ´¨*cascade08
¨Æ Æ∞*cascade08
∞± ±≥*cascade08
≥¥ ¥∑*cascade08
∑∏ ∏∫*cascade08
∫ª ª¡*cascade08
¡√ √»*cascade08
»… …À*cascade08
ÀÕ Õ–*cascade08
–Á ÁË*cascade08
ËÎ ÎÏ*cascade08
ÏÔ ÔÚ*cascade08
Úı ıˆ*cascade08
ˆ˙ ˙˚*cascade08
˚˝ ˝˛*cascade08
˛Ä ÄÇ*cascade08
ÇÉ Éá*cascade08
áà àâ*cascade08
âô ôö*cascade08
ö® ®©*cascade08
©µ µ∂*cascade08
∂¿ ¿¡*cascade08
¡¬ ¬√*cascade08
√À ÀÃ*cascade08
Ã“ “”*cascade08
”‘ ‘Ÿ*cascade08
Ÿ⁄ ⁄›*cascade08
›ﬁ ﬁﬂ*cascade08
ﬂÁ ÁÈ*cascade08
ÈÍ ÍÛ*cascade08
ÛÙ Ùı*cascade08
ıÑ ÑÖ*cascade08
Öá áä*cascade08
äã ãì*cascade08
ìî îï*cascade08
ïô ôö*cascade08
öõ õü*cascade08
ü° °¢*cascade08
¢® ®´*cascade08
´¨ ¨≠*cascade08
≠Æ Æ±*cascade08
±≥ ≥µ*cascade08
µ∂ ∂∏*cascade08
∏π πª*cascade08
ªº ºΩ*cascade08
Ω   Ã*cascade08
ÃÕ ÕŒ*cascade08
Œœ œ—*cascade08
—“ “‘*cascade08
‘„ „Â*cascade08
ÂÁ ÁÈ*cascade08
ÈÍ ÍÎ*cascade08
Î˝ ˝˛*cascade08
˛É Éã*cascade08
ãê êí*cascade08
íì ìî*cascade08
îï ïñ*cascade08
ñ¢ ¢£*cascade08
£§ §•*cascade08
•¶ ¶®*cascade08
®∑ ∑π*cascade08
π∫ ∫Ω*cascade08
Ωæ æø*cascade08
ø¿ ¿√*cascade08
√≈ ≈∆*cascade08
∆» »…*cascade08
…œ œ–*cascade08
–Â ÂÁ*cascade08
ÁÈ ÈÍ*cascade08
ÍÏ ÏÔ*cascade08
ÔÒ ÒÛ*cascade08
ÛÙ Ùı*cascade08
ıà àâ*cascade08
âä äã*cascade08
ãå åé*cascade08
éè èë*cascade08
ëï ïñ*cascade08
ñ© ©´*cascade08
´≤ ≤≥*cascade08
≥∑ ∑∫*cascade08
∫ª ªΩ*cascade08
Ω— —÷*cascade08
÷⁄ ⁄‡*cascade08
‡á áà*cascade08
àî îï*cascade08
ïù ùû*cascade08
û§ §•*cascade08
•Ø Ø±*cascade08
±≥ ≥∑*cascade08
∑∏ ∏º*cascade08
ºÓ Óü*cascade08
ü° °…<*cascade08
…<›< "(12943f395cb517520c157a38018bef633d4291d72lfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/create_role_screen.dart:Hfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp