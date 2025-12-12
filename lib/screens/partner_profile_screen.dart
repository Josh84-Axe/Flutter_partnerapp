import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/app_theme.dart';
import '../providers/app_state.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../utils/country_utils.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    
    // Initialize controllers with user data
    _companyNameController.text = user?.name ?? '';
    _addressController.text = user?.address ?? '';
    _phoneController.text = user?.phone ?? '';
    _emailController.text = user?.email ?? '';
    _cityController.text = user?.city ?? '';
    _countryController.text = user?.country ?? '';
    _routersController.text = user?.numberOfRouters?.toString() ?? '';
    
    // Load payment methods
    await appState.loadPaymentMethods();
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

  void _showOtpValidation() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pushNamed('/otp-validation', arguments: {
      'purpose': 'verify_profile_changes'.tr(),
      'onVerified': () async {
        Navigator.of(context).pop(); // Close OTP screen
        
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        final appState = context.read<AppState>();
        
        // Split name into first/last
        final nameParts = _companyNameController.text.trim().split(' ');
        final firstName = nameParts.first;
        final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        
        final success = await appState.updatePartnerProfile(
          firstName: firstName,
          lastName: lastName,
          businessName: _companyNameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          city: _cityController.text,
          country: _countryController.text,
        );

        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('profile_updated_success'.tr()),
                backgroundColor: AppTheme.successGreen,
              ),
            );
            Navigator.of(context).pop(); // Exit profile screen
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(appState.error ?? 'failed_update_profile'.tr()),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        }
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appState = context.read<AppState>();

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
                      _buildDetailRow('partner_id'.tr(), appState.currentUser?.id ?? 'N/A'),
                      const Divider(height: 24),
                      _buildDetailRow('registration_date'.tr(), 
                        appState.currentUser?.createdAt != null 
                          ? DateFormat('MMM d, yyyy').format(appState.currentUser!.createdAt) 
                          : 'N/A'
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'account_status'.tr(), 
                        appState.currentUser?.isActive == true ? 'active'.tr() : 'inactive'.tr(),
                        valueColor: appState.currentUser?.isActive == true ? AppTheme.successGreen : AppTheme.errorRed,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow('role'.tr(), appState.currentUser?.role.toUpperCase() ?? 'N/A'),
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
                    initialValue: PhoneNumber(isoCode: CountryUtils.getIsoCode(appState.partnerCountry ?? 'Togo')),
                    textFieldController: _phoneController,
                    formatInput: true,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    inputDecoration: InputDecoration(
                      labelText: 'Contact Number',
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
                        return 'Contact Number is required';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Business Address',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _countryController,
                  label: 'Country',
                  icon: Icons.flag,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _routersController,
                  label: 'Number of Routers',
                  icon: Icons.router,
                  keyboardType: TextInputType.number,
                ),

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
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _showOtpValidation,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
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
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
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
        title: const Text('Delete Payment Method'),
        content: const Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<AppState>().deletePaymentMethod(methodId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment method deleted successfully'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete payment method: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  void _addPaymentMethod() async {
    final result = await Navigator.of(context).pushNamed('/add-payout-method');
    if (result == true && mounted) {
      // Reload payment methods after adding
      context.read<AppState>().loadPaymentMethods();
    }
  }
}
