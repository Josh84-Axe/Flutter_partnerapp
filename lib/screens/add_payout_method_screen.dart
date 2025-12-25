import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split/billing_provider.dart';
import '../providers/split/auth_provider.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../utils/country_utils.dart';

class AddPayoutMethodScreen extends StatefulWidget {
  const AddPayoutMethodScreen({super.key});

  @override
  State<AddPayoutMethodScreen> createState() => _AddPayoutMethodScreenState();
}

class _AddPayoutMethodScreenState extends State<AddPayoutMethodScreen> {
  String _currentScreen = 'selection';
  String _selectedMethod = '';

  final _mobileMoneyFormKey = GlobalKey<FormState>();
  final _bankTransferFormKey = GlobalKey<FormState>();

  final _mobileProviderController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _mobileHolderNameController = TextEditingController();

  final _bankNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankHolderNameController = TextEditingController();
  final _swiftIbanController = TextEditingController();

  @override
  void dispose() {
    _mobileProviderController.dispose();
    _mobileNumberController.dispose();
    _mobileHolderNameController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankHolderNameController.dispose();
    _swiftIbanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Payout Method'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentScreen == 'selection') {
              Navigator.pop(context);
            } else {
              setState(() {
                _currentScreen = 'selection';
              });
            }
          },
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _currentScreen == 'selection'
            ? _buildSelectionScreen()
            : _buildFormScreen(),
      ),
    );
  }

  Widget _buildSelectionScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please select a payout method to add.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          _buildMethodCard(
            'Add Mobile Money Details',
            'Receive payments directly to your mobile number.',
            Icons.smartphone,
            () {
              setState(() {
                _currentScreen = 'mobileMoney';
                _selectedMethod = 'mobile';
              });
            },
          ),
          const SizedBox(height: 16),
          _buildMethodCard(
            'Add Bank Transfer Details',
            'Get funds deposited into your bank account.',
            Icons.account_balance,
            () {
              setState(() {
                _currentScreen = 'bankTransfer';
                _selectedMethod = 'bank';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(String title, String description, IconData icon, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormScreen() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_selectedMethod == 'mobile') _buildMobileMoneyForm(),
          if (_selectedMethod == 'bank') _buildBankTransferForm(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentScreen = 'selection';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Save Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMoneyForm() {
    return Form(
      key: _mobileMoneyFormKey,
      child: Column(
        children: [
          _buildTextField(
            label: 'Mobile Money Provider',
            controller: _mobileProviderController,
            isDropdown: true,
            dropdownItems: ['MTN Mobile Money', 'Airtel Money', 'Vodafone Cash'],
          ),
          const SizedBox(height: 20),
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
            selectorTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            initialValue: PhoneNumber(isoCode: CountryUtils.getIsoCode(context.read<AuthProvider>().partnerCountry ?? 'Togo')),
            textFieldController: _mobileNumberController,
            formatInput: true,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            inputDecoration: InputDecoration(
              labelText: 'Mobile Money Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Mobile Money Number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Account Holder Name',
            controller: _mobileHolderNameController,
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferForm() {
    return Form(
      key: _bankTransferFormKey,
      child: Column(
        children: [
          _buildTextField(
            label: 'Bank Name',
            controller: _bankNameController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Bank Account Number',
            controller: _bankAccountNumberController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Account Holder Name',
            controller: _bankHolderNameController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'SWIFT/IBAN Code',
            controller: _swiftIbanController,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool isDropdown = false,
    List<String>? dropdownItems,
  }) {
    if (isDropdown && dropdownItems != null) {
      return DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        items: dropdownItems.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (value) {
          controller.text = value ?? '';
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      );
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  void _saveDetails() async {
    bool isValid = false;
    if (_selectedMethod == 'mobile') {
      isValid = _mobileMoneyFormKey.currentState?.validate() ?? false;
    } else if (_selectedMethod == 'bank') {
      isValid = _bankTransferFormKey.currentState?.validate() ?? false;
    }

    if (isValid) {
      try {
        // Prepare data for API with correct field names
        final Map<String, dynamic> paymentData = {};
        
        if (_selectedMethod == 'mobile') {
          paymentData['name'] = _mobileProviderController.text; // Provider name (e.g., "MTN Mobile Money")
          paymentData['numbers'] = _mobileNumberController.text; // Mobile number
          paymentData['account_holder_name'] = _mobileHolderNameController.text;
          paymentData['description'] = 'Mobile Money - ${_mobileProviderController.text}';
        } else if (_selectedMethod == 'bank') {
          paymentData['name'] = _bankNameController.text; // Bank name
          paymentData['numbers'] = _bankAccountNumberController.text; // Account number
          paymentData['account_holder_name'] = _bankHolderNameController.text;
          paymentData['description'] = 'Bank Transfer - ${_bankNameController.text}${_swiftIbanController.text.isNotEmpty ? ' (SWIFT: ${_swiftIbanController.text})' : ''}';
        }
        
        // Request OTP
        final billingProvider = context.read<BillingProvider>();
        await billingProvider.requestPaymentMethodOtp(paymentData);
        
        if (context.mounted) {
          // Show OTP verification dialog
          final otpController = TextEditingController();
          final verified = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Verify Payment Method'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter the OTP code sent to your registered contact.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: InputDecoration(
                      hintText: '000000',
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final otp = otpController.text.trim();
                    if (otp.length == 6) {
                      try {
                        await billingProvider.verifyPaymentMethodOtp(otp);
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Verification failed: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Verify'),
                ),
              ],
            ),
          );
          
          if (verified == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment method added successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to request OTP: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
