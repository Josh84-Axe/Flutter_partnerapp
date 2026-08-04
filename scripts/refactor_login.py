import os
import re

file_path = "/Users/josh/Family_App/lib/feature/auth/login_screen_m3.dart"
with open(file_path, "r") as f:
    content = f.read()

# 1. Remove appVariant from LoginScreenM3 signature
content = re.sub(
    r"class LoginScreenM3 extends StatefulWidget \{\n  final String appVariant;\n  const LoginScreenM3\(\{super\.key, this\.appVariant = 'partner'\}\);",
    "class LoginScreenM3 extends StatefulWidget {\n  const LoginScreenM3({super.key});",
    content
)

# 2. Add flavors import
content = content.replace("import '../../theme/tiknet_themes.dart';", "import '../../theme/tiknet_themes.dart';\nimport '../../flavors.dart';")

# 3. Remove state variables and initialization
content = re.sub(
    r"  late String _currentVariant;\n  bool _isVariantLoading = true;\n\n  @override\n  void initState\(\) \{\n    super\.initState\(\);\n    _currentVariant = widget\.appVariant;\n    _loadInitData\(\);\n  \}",
    "  @override\n  void initState() {\n    super.initState();\n    _loadInitData();\n  }",
    content
)

content = re.sub(
    r"    final cachedVariant = prefs\.getString\('cached_app_variant'\);\n    \n    if \(mounted\) \{\n      setState\(\(\) \{\n        if \(cachedVariant != null && cachedVariant\.isNotEmpty\) \{\n          _currentVariant = cachedVariant;\n        \} else if \(widget\.appVariant\.isNotEmpty\) \{\n          _currentVariant = widget\.appVariant;\n        \} else \{\n          _currentVariant = 'partner'; // Default fallback\n        \}\n        _isVariantLoading = false;",
    "    if (mounted) {\n      setState(() {",
    content
)

# 4. Use F.name for login calls instead of _currentVariant
content = content.replace("overrideVariant: _currentVariant", "overrideVariant: F.name")

# 5. Remove _isVariantLoading check in build
content = re.sub(
    r"    if \(_isVariantLoading\) \{\n      return const Scaffold\(\n        body: Center\(\n          child: CircularProgressIndicator\(\),\n        \),\n      \);\n    \}\n\n    ThemeData variantTheme;\n    if \(_currentVariant == 'family'\) \{\n      variantTheme = TiknetThemes\.getElevatedDynamicBlueTheme\(\);\n    \} else if \(_currentVariant == 'campus'\) \{\n      variantTheme = TiknetThemes\.getVibrantOrangeTheme\(\);\n    \} else \{\n      variantTheme = TiknetThemes\.getFlatLightGreenTheme\(\);\n    \}\n\n    final scheme = variantTheme\.colorScheme;\n    final colorScheme = scheme;",
    "    final scheme = Theme.of(context).colorScheme;\n    final colorScheme = scheme;",
    content
)

# 6. Remove Theme wrapper and just use Scaffold
content = re.sub(
    r"    return Theme\(\n      data: variantTheme,\n      child: Builder\(\n        builder: \(context\) \{\n          return Scaffold\(",
    "    return Scaffold(",
    content
)

content = content.replace("_currentVariant == 'family'", "F.name == 'family'")
content = content.replace("_currentVariant == 'campus'", "F.name == 'campus'")

# 7. Remove the SegmentedButton completely
content = re.sub(
    r"                      // Flavor Selector\n                      Center\(\n                        child: SegmentedButton<String>\(.*?                      \),\n                      const SizedBox\(height: 24\),\n",
    "",
    content,
    flags=re.DOTALL
)

# 8. Remove the Positioned Dropdown completely
content = re.sub(
    r"                Positioned\(\n                  top: 16,\n                  right: 16,\n                  child: Card\(\n                    color: scheme\.surface,\n                    elevation: 4,\n                    child: Padding\(\n                      padding: const EdgeInsets\.symmetric\(horizontal: 12\),\n                      child: DropdownButtonHideUnderline\(\n                        child: DropdownButton<String>\(\n                          value: _currentVariant,\n                          items: const \[\n                            DropdownMenuItem\(value: 'partner', child: Text\('Partner'\)\),\n                            DropdownMenuItem\(value: 'family', child: Text\('Family'\)\),\n                            DropdownMenuItem\(value: 'campus', child: Text\('Campus'\)\),\n                          \],\n                          onChanged: \(val\) \{\n                            if \(val != null\) \{\n                              setState\(\(\) => _currentVariant = val\);\n                            \}\n                          \},\n                        \),\n                      \),\n                    \),\n                  \),\n                \),\n",
    "",
    content,
    flags=re.DOTALL
)

# Fix the trailing Builder brace (since we removed Theme and Builder wrappers)
content = re.sub(
    r"            \),\n          \);\n        \},\n      \),\n    \);\n  \}\n\}",
    "            ),\n          );\n  }\n}",
    content
)

with open(file_path, "w") as f:
    f.write(content)
