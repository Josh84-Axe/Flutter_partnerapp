import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/app_theme.dart';
import '../providers/split/user_provider.dart';
import '../providers/split/auth_provider.dart';
import '../providers/split/billing_provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../utils/country_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

class PartnerProfileScreen extends StatefulWidget {
  const PartnerProfileScreen({super.key});

  @override
  State<PartnerProfileScreen> createState() => _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends State<PartnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _routersController = TextEditingController();
  
  XFile? _selectedImage;
  String? _currentHeroImageUrl;
  String? _selectedHexCode;

  final List<String> _presetColors = [
    '#D32F2F', // Red
    '#C2185B', // Pink
    '#7B1FA2', // Purple
    '#303F9F', // Indigo
    '#1976D2', // Blue
    '#0097A7', // Cyan
    '#00796B', // Teal
    '#388E3C', // Green
    '#FBC02D', // Yellow
    '#F57C00', // Orange
    '#5D4037', // Brown
    '#000000', // Black
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    final authProvider = context.read<AuthProvider>();
    final billingProvider = context.read<BillingProvider>();
    final user = authProvider.currentUser;
    
    // Initialize controllers with user data
    _companyNameController.text = user?.name ?? '';
    _addressController.text = user?.address ?? '';
    _phoneController.text = user?.phone ?? '';
    _emailController.text = user?.email ?? '';
    _cityController.text = user?.city ?? '';
    _countryController.text = user?.country ?? '';
    _routersController.text = user?.numberOfRouters?.toString() ?? '';
    _selectedHexCode = user?.primaryHex;
    _currentHeroImageUrl = user?.heroImageUrl;
    
    // Load payment methods
    await billingProvider.loadPaymentMethods();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _routersController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final authProvider = context.read<AuthProvider>();
    
    // Split name into first/last
    final nameParts = _companyNameController.text.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    // Construct address
    final fullAddress = _addressController.text.trim();
    
    final Map<String, dynamic> updateData = {
      'first_name': firstName,
      'last_name': lastName,
      'business_name': _companyNameController.text,
      'phone': _phoneController.text,
      'address': fullAddress,
      'city': _cityController.text,
      'country': _countryController.text,
      'number_of_routers': int.tryParse(_routersController.text) ?? 0,
      'portal_primary_hex': _selectedHexCode,
      'portal_hero_image': _selectedImage,
    };
    
    final success = await authProvider.updateProfile(updateData);

    if (mounted) {
      Navigator.of(context).pop(); // Close loading dialog
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('profile_updated_success'.tr()),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        // Re-load user profile to get the updated data (including new hero image URL)
        await authProvider.checkAuthStatus();
        // Refresh local state with new data from provider
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'failed_update_profile'.tr()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = context.watch<AuthProvider>();
    final billingProvider = context.watch<BillingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('partner_profile_title'.tr()),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'registration_details'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('partner_id'.tr(), authProvider.currentUser?.id ?? 'N/A'),
                      const Divider(height: 24),
                      _buildDetailRow('registration_date'.tr(), 
                        authProvider.currentUser?.createdAt != null 
                          ? DateFormat('MMM d, yyyy').format(authProvider.currentUser!.createdAt) 
                          : 'N/A'
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'account_status'.tr(), 
                        authProvider.currentUser?.isActive == true ? 'active'.tr() : 'inactive'.tr(),
                        valueColor: authProvider.currentUser?.isActive == true ? AppTheme.successGreen : AppTheme.errorRed,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow('role'.tr(), authProvider.currentUser?.role.toUpperCase() ?? 'N/A'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'basic_information'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _companyNameController,
                  label: 'full_name_business_name'.tr(),
                  icon: Icons.business,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'email_address'.tr(),
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                  InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      // Controller is updated automatically
                    },
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      setSelectorButtonAsPrefixIcon: true,
                      leadingPadding: 12,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: TextStyle(color: colorScheme.onSurface),
                    initialValue: PhoneNumber(isoCode: CountryUtils.getIsoCode(authProvider.partnerCountry ?? 'Togo')),
                    textFieldController: _phoneController,
                    formatInput: true,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    inputDecoration: InputDecoration(
                      labelText: 'contact_number'.tr(),
                      prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.primary, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'contact_number_required'.tr();
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'business_address'.tr(),
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cityController,
                  label: 'city'.tr(),
                  icon: Icons.location_city,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _countryController,
                  label: 'country'.tr(),
                  icon: Icons.flag,
                ),
                _buildTextField(
                  controller: _routersController,
                  label: 'number_of_routers'.tr(),
                  icon: Icons.router,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                _buildBrandingSection(),
                const SizedBox(height: 32),
              ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: authProvider.isLoading ? null : _updateProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authProvider.isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'save_changes'.tr(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBrandingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.palette_outlined, size: 20, color: AppTheme.textDark),
            const SizedBox(width: 8),
            Text(
              'branding'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildImagePicker(),
        const SizedBox(height: 24),
        _buildColorPalette(),
      ],
    );
  }

  Widget _buildColorPalette() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'portal_color_hex'.tr(),
          style: const TextStyle(
            fontSize: 15, 
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _presetColors.map((hex) {
              final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
              final isSelected = _selectedHexCode == hex;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedHexCode = hex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? colorScheme.primary : Colors.transparent,
                      width: 4,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 28)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'portal_hero_image'.tr(),
              style: const TextStyle(
                fontSize: 15, 
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            IconButton(
              icon: Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('portal_hero_image'.tr()),
                    content: Text('hero_image_specs'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('ok'.tr()),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        if (_selectedImage == null && _currentHeroImageUrl == null) ...[
          const SizedBox(height: 8),
          Text(
            'hero_image_tip'.tr(),
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                style: _selectedImage == null && _currentHeroImageUrl == null 
                    ? BorderStyle.solid 
                    : BorderStyle.none,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Image Display
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _selectedImage != null
                      ? (kIsWeb 
                          ? Image.network(
                              _selectedImage!.path, 
                              width: double.infinity, 
                              height: 180, 
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              io.File(_selectedImage!.path), 
                              width: double.infinity, 
                              height: 180, 
                              fit: BoxFit.cover,
                            ))
                      : (_currentHeroImageUrl != null && _currentHeroImageUrl!.isNotEmpty
                          ? Image.network(
                              _currentHeroImageUrl!, 
                              width: double.infinity, 
                              height: 180, 
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder()),
                ),
                
                // Edit Overlay
                if (_selectedImage != null || _currentHeroImageUrl != null)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'change'.tr(),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 75,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Determine method type and icon
    final methodType = method['method_type']?.toString() ?? '';
    final provider = method['provider']?.toString() ?? '';
    final accountNumber = method['account_number']?.toString() ?? '';
    final methodId = method['id']?.toString() ?? '';
    
    IconData iconData = methodType == 'mobile_money' 
        ? Icons.phone_android 
        : Icons.account_balance;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: Icon(iconData, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    methodType == 'mobile_money' ? 'Mobile Money' : 'Bank Transfer',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    accountNumber,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20),
              onPressed: () => _deletePaymentMethod(methodId),
              color: AppTheme.errorRed,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePaymentMethod(String methodId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_payment_method_title'.tr()),
        content: Text('delete_payment_method_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<BillingProvider>().deletePaymentMethod(methodId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('payment_method_deleted'.tr())),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('payment_method_delete_failed'.tr(namedArgs: {'error': e.toString()}))),
          );
        }
      }
    }
  }

  void _addPaymentMethod() async {
    final result = await Navigator.of(context).pushNamed('/add-payout-method');
    if (result == true && mounted) {
      // Reload payment methods after adding
      context.read<BillingProvider>().loadPaymentMethods();
    }
  }

  Widget _buildPlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: 180,
      color: colorScheme.surfaceVariant.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'tap_to_select_image'.tr(),
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
