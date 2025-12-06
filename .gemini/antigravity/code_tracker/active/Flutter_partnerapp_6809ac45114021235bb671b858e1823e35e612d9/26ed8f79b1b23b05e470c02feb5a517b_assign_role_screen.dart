ªRimport 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/app_state.dart';
import '../utils/app_theme.dart';

class AssignRoleScreen extends StatefulWidget {
  const AssignRoleScreen({super.key});

  @override
  State<AssignRoleScreen> createState() => _AssignRoleScreenState();
}

class _AssignRoleScreenState extends State<AssignRoleScreen> {
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadWorkers();
      context.read<AppState>().loadRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final appState = context.watch<AppState>();
    final workers = appState.workers;

    return Scaffold(
      appBar: AppBar(
        title: Text('assign_change_role'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_workers'.tr(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: workers.isEmpty
                ? Center(child: Text('no_workers_found'.tr()))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: workers.length,
                    itemBuilder: (context, index) {
                      final worker = workers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            child: Text(
                              worker.name.isNotEmpty ? worker.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            worker.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(worker.email),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getRoleBadgeColor(worker.role).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              worker.role,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getRoleBadgeColor(worker.role),
                              ),
                            ),
                          ),
                          onTap: () {
                            _showRoleSelector(context, worker);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getRoleBadgeColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return Colors.purple;
      case 'manager':
        return Colors.teal;
      case 'worker':
        return Colors.orange;
      default:
        return AppTheme.textLight;
    }
  }

  void _showRoleSelector(BuildContext context, worker) {
    final appState = context.read<AppState>();
    final roles = appState.roles;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.textLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'select_new_role'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  worker.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 24),
                if (roles.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('no_roles_available'.tr()),
                  )
                else
                  ...roles.map((role) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildRoleOption(
                      context,
                      setModalState,
                      role.name,
                      role.slug,
                      worker.role.toLowerCase() == role.slug.toLowerCase() || worker.role.toLowerCase() == role.name.toLowerCase(),
                    ),
                  )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (_selectedRole != null) {
                        Navigator.pop(context);
                        try {
                          await appState.assignRoleToWorker(worker.username, _selectedRole!);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('role_updated_to'.tr(namedArgs: {'role': _selectedRole!})),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error assigning role: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('update_role'.tr()),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('cancel'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context,
    StateSetter setModalState,
    String label,
    String value,
    bool isCurrentRole,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedRole == value || (isCurrentRole && _selectedRole == null);
    
    return GestureDetector(
      onTap: () {
        setModalState(() {
          _selectedRole = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : AppTheme.textLight.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? colorScheme.primary : AppTheme.textDark,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
˘ ˘ÿ*cascade08
ÿÛ Û˜*cascade08
˜Ü Üä*cascade08
äÁ
 Á
Î
*cascade08
Î
Í ÍÕ*cascade08
Õ‡ ‡Ê*cascade08
Ê∏ ∏æ*cascade08
æ… …Õ*cascade08
Õ⁄ ⁄‡*cascade08
‡ü ü•*cascade08
•´ ´Ø*cascade08
Ø¥ ¥∏*cascade08
∏≈ ≈∆*cascade08
∆÷ ÷€*cascade08
€È ÈÔ*cascade08
Ô¨ ¨Ø*cascade08
Ø¡ ¡ƒ*cascade08
ƒ÷ ÷‹*cascade08
‹à àç*cascade08
ç£ £§*cascade08
§ä äê*cascade08
ê∂ ∂…*cascade08
…   Ÿ*cascade08
ŸÒ Ò˜*cascade08
˜˙ ˙Ä*cascade08
Ä´ ´≠*cascade08
≠« «À*cascade08
Àî îö*cascade08
ö∏ ∏Ω*cascade08
Ω’ ’÷*cascade08
÷⁄ ⁄‡*cascade08
‡é éî*cascade08
îò òô*cascade08
ô≠ ≠≤*cascade08
≤÷ ÷‡*cascade08
‡Í Í*cascade08
º º¡*cascade08
¡’ ’÷*cascade08
÷⁄ ⁄‡*cascade08
‡É Éá*cascade08
áì ìî*cascade08
î® ®≠*cascade08
≠√ √…*cascade08
…¢ ¢•*cascade08
•ª ªæ*cascade08
æÚ Ú¯*cascade08
¯í íñ*cascade08
ñ∏ ∏æ*cascade08
æñ ñú*cascade08
ú† †°*cascade08
°∑ ∑º*cascade08
º‚ ‚Ï*cascade08
Ïˆ ˆ¸*cascade08
¸ß ß≠*cascade08
≠ ˆ*cascade08
ˆÆ Æ¥*cascade08
¥Œ Œ“*cascade08
“ı ı˚*cascade08
˚ˇ ˇÉ*cascade08
Éô ôõ*cascade08
õü ü•*cascade08
•Ω Ω√*cascade08
√˙ ˙Ä *cascade08
Ä õ  õ ü *cascade08
ü •  • ß *cascade08
ß ª  ª ø *cascade08
ø √  √ … *cascade08
… ﬂ  ﬂ „ *cascade08
„ Û  Û ı *cascade08
ı ˘  ˘ ˇ *cascade08
ˇ ë! ë!ó!*cascade08
ó!Ω" Ω"⁄"*cascade08
⁄"”$ ”$◊$*cascade08
◊$‹$ ‹$±%*cascade08
±%Ô/ Ô/Û/*cascade08
Û/›1 ›1·1*cascade08
·1‰1 ‰1Í1*cascade08
Í1Ï1 Ï1Ü2*cascade08
Ü2à2 à2â2*cascade08
â2û2 û2©2*cascade08
©2¨2 ¨2≠2*cascade08
≠2Æ2 Æ2∂2*cascade08
∂2∏2 ∏2√2*cascade08
√2ÿ2 ÿ2‚2*cascade08
‚2„2 „2‰2*cascade08
‰2Â2 Â2Ë2*cascade08
Ë2È2 È22*cascade08
2Ò2 Ò2Ù2*cascade08
Ù2ˆ2 ˆ2¯2*cascade08
¯2˘2 ˘2Ä3*cascade08
Ä3ï3 ï3ñ3*cascade08
ñ3®3 ®3¨3*cascade08
¨3¿3 ¿3¬3*cascade08
¬3«3 «3»3*cascade08
»3…3 …3Œ3*cascade08
Œ3œ3 œ3—3*cascade08
—3’3 ’3÷3*cascade08
÷3◊3 ◊3ÿ3*cascade08
ÿ3⁄3 ⁄3€3*cascade08
€3›3 ›3ﬂ3*cascade08
ﬂ3ı3 ı3˝3*cascade08
˝3Ñ4 Ñ4Ö4*cascade08
Ö4Ü4 Ü4è4*cascade08
è4ê4 ê4ì4*cascade08
ì4î4 î4ó4*cascade08
ó4ò4 ò4ö4*cascade08
ö4¢4 ¢4¶4*cascade08
¶4∂4 ∂4Ω4*cascade08
Ω4–4 –4”4*cascade08
”4Â4 Â4Ê4*cascade08
Ê44 4Ù4*cascade08
Ù4®5 ®5±5*cascade08
±5≥5 ≥5¥5*cascade08
¥5 5  5Œ5*cascade08
Œ5œ5 œ5◊5*cascade08
◊5Ï5 Ï5î6*cascade08
î6ï6 ï6†6*cascade08
†6°6 °6¨6*cascade08
¨6≈6 ≈6 6*cascade08
 6Ã6 Ã6‘6*cascade08
‘6÷6 ÷6Ù6*cascade08
Ù6˜6 ˜6¯6*cascade08
¯6à7 à7ä7*cascade08
ä7∂7 ∂7∑7*cascade08
∑7À7 À7Ã7*cascade08
Ã7Õ7 Õ7œ7*cascade08
œ7–7 –7—7*cascade08
—7“7 “7Û7*cascade08
Û7ı7 ı7¸7*cascade08
¸7˝7 ˝7ï8*cascade08
ï8ñ8 ñ8§8*cascade08
§8ª8 ª8Ω8*cascade08
Ω8ø8 ø8¡8*cascade08
¡8¬8 ¬8“8*cascade08
“8Ê8 Ê8Ô8*cascade08
Ô8Ò8 Ò8Ù8*cascade08
Ù8ı8 ı8¯8*cascade08
¯8˚8 ˚8Ü9*cascade08
Ü9ö9 ö9ß9*cascade08
ß9©9 ©9≤9*cascade08
≤9≥9 ≥9∑9*cascade08
∑9À9 À9“9*cascade08
“9”9 ”9÷9*cascade08
÷9Í9 Í9ˇ9*cascade08
ˇ9Å: Å:à:*cascade08
à:ã: ã:å:*cascade08
å:ç: ç:é:*cascade08
é:ê: ê:ë:*cascade08
ë:í: í:ì:*cascade08
ì:ö: ö:£:*cascade08
£:§: §:µ:*cascade08
µ:«: «:‰:*cascade08
‰:Â: Â:Á:*cascade08
Á:È: È:Ò:*cascade08
Ò:Å; Å;Ü;*cascade08
Ü;á; á;ä;*cascade08
ä;ã; ã;è;*cascade08
è;ê; ê;ë;*cascade08
ë;í; í;ó;*cascade08
ó;ò; ò;ô;*cascade08
ô;ö; ö;û;*cascade08
û;ü; ü;†;*cascade08
†;¢; ¢;∞;*cascade08
∞;≤; ≤;ø;*cascade08
ø;œ; œ;–;*cascade08
–;—; —;’;*cascade08
’;÷; ÷;ÿ;*cascade08
ÿ;Ì; Ì;˛;*cascade08
˛;ˇ; ˇ;Ç<*cascade08
Ç<Ñ< Ñ<ã<*cascade08
ã<é< é<ö<*cascade08
ö<õ< õ<û<*cascade08
û<ü< ü<∏<*cascade08
∏<π< π<√<*cascade08
√<ÿ< ÿ<é=*cascade08
é=è= è=£=*cascade08
£=•= •=¶=*cascade08
¶=∫= ∫=ƒ=*cascade08
ƒ=∆= ∆=«=*cascade08
«=‚= ‚=Ê=*cascade08
Ê=Á= Á=È=*cascade08
È=Ò= Ò=˘=*cascade08
˘=˙= ˙=¸=*cascade08
¸=˛= ˛=Ñ>*cascade08
Ñ>ﬂ> ﬂ>Â>*cascade08
Â>> >ˆ>*cascade08
ˆ>ü? ü?†?*cascade08
†?°? °?¢?*cascade08
¢?§? §?•?*cascade08
•?¶? ¶?≠?*cascade08
≠?µ? µ?∂?*cascade08
∂?∑? ∑?ﬁ?*cascade08
ﬁ?ﬂ? ﬂ?Â?*cascade08
Â?Ê? Ê?Á?*cascade08
Á?È? È?Ï?*cascade08
Ï?Ì? Ì?Ò?*cascade08
Ò?Ú? Ú?Û?*cascade08
Û?ˆ? ˆ?˜?*cascade08
˜?˙? ˙?Ä@*cascade08
Ä@≤@ ≤@∏@*cascade08
∏@∫@ ∫@ãA*cascade08
ãAªR "(6809ac45114021235bb671b858e1823e35e612d92lfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp/lib/screens/assign_role_screen.dart:Hfile:///c:/Users/ELITEX21012G2/antigravity_partnerapp/Flutter_partnerapp