import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import '../providers/split/auth_provider.dart';
import '../utils/app_theme.dart';
import '../utils/ip_geolocation.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../utils/error_message_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController(); // Confirm password
  bool _isLogin = true;
  final _nameController = TextEditingController(); // First Name
  final _enterpriseNameController = TextEditingController(); // Enterprise Name
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _numberOfRoutersController = TextEditingController();
  String? _selectedCountry; // Will be set from IP geolocation
  
  // Comprehensive ISO country codes
  final Map<String, String> _countries = {
    'AF': 'Afghanistan', 'AL': 'Albania', 'DZ': 'Algeria', 'AD': 'Andorra', 'AO': 'Angola',
    'AR': 'Argentina', 'AM': 'Armenia', 'AU': 'Australia', 'AT': 'Austria', 'AZ': 'Azerbaijan',
    'BS': 'Bahamas', 'BH': 'Bahrain', 'BD': 'Bangladesh', 'BB': 'Barbados', 'BY': 'Belarus',
    'BE': 'Belgium', 'BZ': 'Belize', 'BJ': 'Benin', 'BT': 'Bhutan', 'BO': 'Bolivia',
    'BA': 'Bosnia and Herzegovina', 'BW': 'Botswana', 'BR': 'Brazil', 'BN': 'Brunei', 'BG': 'Bulgaria',
    'BF': 'Burkina Faso', 'BI': 'Burundi', 'KH': 'Cambodia', 'CM': 'Cameroon', 'CA': 'Canada',
    'CV': 'Cape Verde', 'CF': 'Central African Republic', 'TD': 'Chad', 'CL': 'Chile', 'CN': 'China',
    'CO': 'Colombia', 'KM': 'Comoros', 'CG': 'Congo', 'CR': 'Costa Rica', 'HR': 'Croatia',
    'CU': 'Cuba', 'CY': 'Cyprus', 'CZ': 'Czech Republic', 'DK': 'Denmark', 'DJ': 'Djibouti',
    'DM': 'Dominica', 'DO': 'Dominican Republic', 'EC': 'Ecuador', 'EG': 'Egypt', 'SV': 'El Salvador',
    'GQ': 'Equatorial Guinea', 'ER': 'Eritrea', 'EE': 'Estonia', 'ET': 'Ethiopia', 'FJ': 'Fiji',
    'FI': 'Finland', 'FR': 'France', 'GA': 'Gabon', 'GM': 'Gambia', 'GE': 'Georgia',
    'DE': 'Germany', 'GH': 'Ghana', 'GR': 'Greece', 'GD': 'Grenada', 'GT': 'Guatemala',
    'GN': 'Guinea', 'GW': 'Guinea-Bissau', 'GY': 'Guyana', 'HT': 'Haiti', 'HN': 'Honduras',
    'HU': 'Hungary', 'IS': 'Iceland', 'IN': 'India', 'ID': 'Indonesia', 'IR': 'Iran',
    'IQ': 'Iraq', 'IE': 'Ireland', 'IL': 'Israel', 'IT': 'Italy', 'CI': 'Ivory Coast',
    'JM': 'Jamaica', 'JP': 'Japan', 'JO': 'Jordan', 'KZ': 'Kazakhstan', 'KE': 'Kenya',
    'KI': 'Kiribati', 'KW': 'Kuwait', 'KG': 'Kyrgyzstan', 'LA': 'Laos', 'LV': 'Latvia',
    'LB': 'Lebanon', 'LS': 'Lesotho', 'LR': 'Liberia', 'LY': 'Libya', 'LI': 'Liechtenstein',
    'LT': 'Lithuania', 'LU': 'Luxembourg', 'MK': 'North Macedonia', 'MG': 'Madagascar', 'MW': 'Malawi',
    'MY': 'Malaysia', 'MV': 'Maldives', 'ML': 'Mali', 'MT': 'Malta', 'MH': 'Marshall Islands',
    'MR': 'Mauritania', 'MU': 'Mauritius', 'MX': 'Mexico', 'FM': 'Micronesia', 'MD': 'Moldova',
    'MC': 'Monaco', 'MN': 'Mongolia', 'ME': 'Montenegro', 'MA': 'Morocco', 'MZ': 'Mozambique',
    'MM': 'Myanmar', 'NA': 'Namibia', 'NR': 'Nauru', 'NP': 'Nepal', 'NL': 'Netherlands',
    'NZ': 'New Zealand', 'NI': 'Nicaragua', 'NE': 'Niger', 'NG': 'Nigeria', 'KP': 'North Korea',
    'NO': 'Norway', 'OM': 'Oman', 'PK': 'Pakistan', 'PW': 'Palau', 'PA': 'Panama',
    'PG': 'Papua New Guinea', 'PY': 'Paraguay', 'PE': 'Peru', 'PH': 'Philippines', 'PL': 'Poland',
    'PT': 'Portugal', 'QA': 'Qatar', 'RO': 'Romania', 'RU': 'Russia', 'RW': 'Rwanda',
    'KN': 'Saint Kitts and Nevis', 'LC': 'Saint Lucia', 'VC': 'Saint Vincent', 'WS': 'Samoa', 'SM': 'San Marino',
    'ST': 'Sao Tome and Principe', 'SA': 'Saudi Arabia', 'SN': 'Senegal', 'RS': 'Serbia', 'SC': 'Seychelles',
    'SL': 'Sierra Leone', 'SG': 'Singapore', 'SK': 'Slovakia', 'SI': 'Slovenia', 'SB': 'Solomon Islands',
    'SO': 'Somalia', 'ZA': 'South Africa', 'KR': 'South Korea', 'SS': 'South Sudan', 'ES': 'Spain',
    'LK': 'Sri Lanka', 'SD': 'Sudan', 'SR': 'Suriname', 'SZ': 'Eswatini', 'SE': 'Sweden',
    'CH': 'Switzerland', 'SY': 'Syria', 'TW': 'Taiwan', 'TJ': 'Tajikistan', 'TZ': 'Tanzania',
    'TH': 'Thailand', 'TL': 'Timor-Leste', 'TG': 'Togo', 'TO': 'Tonga', 'TT': 'Trinidad and Tobago',
    'TN': 'Tunisia', 'TR': 'Turkey', 'TM': 'Turkmenistan', 'TV': 'Tuvalu', 'UG': 'Uganda',
    'UA': 'Ukraine', 'AE': 'United Arab Emirates', 'GB': 'United Kingdom', 'US': 'United States', 'UY': 'Uruguay',
    'UZ': 'Uzbekistan', 'VU': 'Vanuatu', 'VA': 'Vatican City', 'VE': 'Venezuela', 'VN': 'Vietnam',
    'YE': 'Yemen', 'ZM': 'Zambia', 'ZW': 'Zimbabwe',
  };

  @override
  void initState() {
    super.initState();
    _detectCountryFromIp();
  }

  /// Detect user's country from their IP address
  Future<void> _detectCountryFromIp() async {
    final countryCode = await IpGeolocation.detectCountryCode();
    if (mounted) {
      setState(() {
        _selectedCountry = countryCode;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _enterpriseNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _numberOfRoutersController.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    bool success;

    if (_isLogin) {
      success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      // Validate confirm password
      if (_passwordController.text != _password2Controller.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('passwords_do_not_match'.tr())),
        );
        return;
      }
      
      success = await authProvider.register(
        firstName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        password2: _password2Controller.text,
        phone: _phoneController.text.trim(),
        businessName: _enterpriseNameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        country: _selectedCountry ?? 'TG',
        numberOfRouters: int.tryParse(_numberOfRoutersController.text.trim()) ?? 1,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/logo_tiknet.png',
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'app_title'.tr(),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'manage_wifi_zone'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textLight,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'name'.tr(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_name'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InternationalPhoneNumberInput(
                      key: ValueKey(_selectedCountry), // Rebuild when country changes
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
                      initialValue: PhoneNumber(isoCode: _selectedCountry ?? 'GH'), // Use detected country or Ghana
                      textFieldController: _phoneController,
                      formatInput: true,
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                      inputDecoration: InputDecoration(
                        labelText: 'phone'.tr(),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'register.error.phoneRequired'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _enterpriseNameController,
                      decoration: InputDecoration(
                        labelText: 'enterprise_name'.tr(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_enterprise_name'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'address'.tr(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_address'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'city'.tr(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_city'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCountry,
                      decoration: InputDecoration(
                        labelText: 'country'.tr(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: _countries.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'select_country'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numberOfRoutersController,
                      decoration: InputDecoration(
                        labelText: 'number_of_routers'.tr(),
                        prefixIcon: Icon(Icons.router),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'enter_number_of_routers'.tr();
                        }
                        final number = int.tryParse(value);
                        if (number == null || number < 1) {
                          return 'must_be_one_or_greater'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'email'.tr(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_email'.tr();
                      }
                      if (!value.contains('@')) {
                        return 'enter_valid_email'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'password'.tr(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'enter_password'.tr();
                      }
                      if (value.length < 6) {
                        return 'password_min_length'.tr();
                      }
                      return null;
                    },
                  ),
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password2Controller,
                      decoration: InputDecoration(
                        labelText: 'confirm_password'.tr(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'confirm_password_required'.tr();
                        }
                        if (value != _passwordController.text) {
                          return 'passwords_do_not_match'.tr();
                        }
                        return null;
                      },
                    ),
                  ],
                  if (_isLogin) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/forgot-password');
                        },
                        child: Text(
                          'forgot_password'.tr(),
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (authProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        ErrorMessageHelper.getUserFriendlyMessage(authProvider.error!),
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  FilledButton(
                    onPressed: authProvider.isLoading ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isLogin ? 'login'.tr() : 'register'.tr(),
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      if (_isLogin) {
                        Navigator.of(context).pushNamed('/register');
                      } else {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      }
                    },
                    child: Text(
                      _isLogin ? 'dont_have_account'.tr() : 'already_have_account'.tr(),
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                  if (_isLogin) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        // Enter guest mode with detected country
                        await authProvider.enterGuestMode(countryCode: _selectedCountry);
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        }
                      },
                      icon: Icon(Icons.visibility, size: 18),
                      label: Text('continue_as_guest'.tr()),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
