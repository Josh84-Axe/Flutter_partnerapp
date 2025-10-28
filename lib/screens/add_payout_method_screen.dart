import 'package:flutter/material.dart';

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
          _buildTextField(
            label: 'Mobile Money Number',
            controller: _mobileNumberController,
            keyboardType: TextInputType.phone,
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

  void _saveDetails() {
    bool isValid = false;
    if (_selectedMethod == 'mobile') {
      isValid = _mobileMoneyFormKey.currentState?.validate() ?? false;
    } else if (_selectedMethod == 'bank') {
      isValid = _bankTransferFormKey.currentState?.validate() ?? false;
    }

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payout method saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
