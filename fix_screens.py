import re
import os

with open('/Users/josh/Family_App/lib/screens/family_registration_screen.dart', 'r') as f:
    content = f.read()

# Rename class
content = content.replace('RegistrationScreen', 'FamilyRegistrationScreen')
# Remove unused controllers
content = re.sub(r'  final _businessNameController = TextEditingController\(\);\n', '', content)
content = re.sub(r'  final _addressController = TextEditingController\(\);\n', '', content)
content = re.sub(r'  final _numberOfRoutersController = TextEditingController\(\);\n', '', content)
# Remove dispose
content = re.sub(r'    _businessNameController\.dispose\(\);\n', '', content)
content = re.sub(r'    _addressController\.dispose\(\);\n', '', content)
content = re.sub(r'    _numberOfRoutersController\.dispose\(\);\n', '', content)

# Change authProvider.register call
register_call = """        businessName: '',
        address: '',
        city: _cityController.text.trim(),
        country: _selectedCountry ?? 'GH',
        numberOfRouters: 1,"""
content = re.sub(r'        businessName: _businessNameController\.text\.trim\(\),\n        address: _addressController\.text\.trim\(\),\n        city: _cityController\.text\.trim\(\),\n        country: _selectedCountry \?\? \'GH\',\n        numberOfRouters: int\.tryParse\(_numberOfRoutersController\.text\) \?\? 1,', register_call, content)

# Remove the text fields for business name, address, number of routers
business_name_field = r'                      TextFormField\(\n                        controller: _businessNameController,[\s\S]*?                      const SizedBox\(height: 16\),\n'
address_field = r'                      TextFormField\(\n                        controller: _addressController,[\s\S]*?                      const SizedBox\(height: 16\),\n'
routers_field = r'                      TextFormField\(\n                        controller: _numberOfRoutersController,[\s\S]*?                      const SizedBox\(height: 16\),\n'

content = re.sub(business_name_field, '', content)
content = re.sub(address_field, '', content)
content = re.sub(routers_field, '', content)

with open('/Users/josh/Family_App/lib/screens/family_registration_screen.dart', 'w') as f:
    f.write(content)


with open('/Users/josh/Family_App/lib/screens/campus_registration_screen.dart', 'r') as f:
    content2 = f.read()

# Rename class
content2 = content2.replace('RegistrationScreen', 'CampusRegistrationScreen')

# Change business name to institution name
content2 = content2.replace('_businessNameController', '_institutionNameController')
content2 = content2.replace("'register.form.businessName'.tr()", "'register.form.institutionName'.tr()")
content2 = content2.replace("'register.error.businessNameRequired'.tr()", "'register.error.institutionNameRequired'.tr()")
content2 = content2.replace("businessName: _businessNameController", "businessName: _institutionNameController")
# Number of routers to Number of students/dorms
content2 = content2.replace("'register.form.routers'.tr()", "'register.form.students'.tr()")

with open('/Users/josh/Family_App/lib/screens/campus_registration_screen.dart', 'w') as f:
    f.write(content2)
