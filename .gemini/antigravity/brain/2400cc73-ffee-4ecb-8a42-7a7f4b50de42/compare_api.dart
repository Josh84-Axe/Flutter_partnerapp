import 'dart:convert';
import 'dart:io';

String normalizePath(String path) {
  // Convert all {param} to {param} to ignore parameter name differences
  // Also remove trailing slashes
  var normalized = path.replaceAll(RegExp(r'\{[^}]+\}'), '{param}');
  if (normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}

Future<Set<String>> loadSwaggerEndpoints(String filepath) async {
  final endpoints = <String>{};
  try {
    final file = File(filepath);
    if (!await file.exists()) {
      print('Swagger file not found: $filepath');
      return endpoints;
    }
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    final paths = data['paths'] as Map<String, dynamic>? ?? {};
    
    const validMethods = {'get', 'put', 'post', 'delete', 'options', 'head', 'patch', 'trace'};
    paths.forEach((path, methods) {
      (methods as Map<String, dynamic>).forEach((method, _) {
        if (validMethods.contains(method.toLowerCase())) {
          endpoints.add('${method.toUpperCase()} ${normalizePath(path)}');
        }
      });
    });
  } catch (e) {
    print('Error loading Swagger: $e');
  }
  return endpoints;
}

Future<Set<String>> loadImplementedEndpoints(String filepath) async {
  final endpoints = <String>{};
  try {
    final file = File(filepath);
    if (!await file.exists()) {
      print('Implemented APIs file not found: $filepath');
      return endpoints;
    }
    final content = await file.readAsString();
    final regex = RegExp(r'- `([A-Z]+) ([^`]+)`');
    
    for (final match in regex.allMatches(content)) {
      final method = match.group(1)!;
      final path = match.group(2)!;
      endpoints.add('$method ${normalizePath(path)}');
    }
  } catch (e) {
    print('Error loading implemented APIs: $e');
  }
  return endpoints;
}

void generateReport(Set<String> swaggerEps, Set<String> implementedEps, String outputPath) {
  final missingInCode = swaggerEps.difference(implementedEps).toList()..sort();
  final extraInCode = implementedEps.difference(swaggerEps).toList()..sort();
  final matched = swaggerEps.intersection(implementedEps).toList()..sort();

  final buffer = StringBuffer();
  buffer.writeln('# API Audit Report');
  buffer.writeln();
  buffer.writeln('Total Swagger Endpoints: ${swaggerEps.length}');
  buffer.writeln('Total Implemented Endpoints: ${implementedEps.length}');
  buffer.writeln('Matched Endpoints: ${matched.length}');
  buffer.writeln();
  
  buffer.writeln('## ❌ Missing in Codebase (Implemented in Swagger but not found in Code)');
  if (missingInCode.isNotEmpty) {
    for (final ep in missingInCode) {
      buffer.writeln('- `$ep`');
    }
  } else {
    buffer.writeln('None! All Swagger endpoints are implemented.');
  }
  
  buffer.writeln();
  buffer.writeln('## ⚠️ Extra in Codebase (Found in Code but not in Swagger)');
  if (extraInCode.isNotEmpty) {
    for (final ep in extraInCode) {
      buffer.writeln('- `$ep`');
    }
  } else {
    buffer.writeln('None! No extra endpoints found in code.');
  }

  final file = File(outputPath);
  file.writeAsStringSync(buffer.toString());
  print('Report saved to $outputPath');
  print(buffer.toString());
}

void main() async {
  final baseDir = r'C:\Users\ELITEX21012G2\.gemini\antigravity\brain\2400cc73-ffee-4ecb-8a42-7a7f4b50de42';
  final swaggerFile = '$baseDir\\swagger.json';
  final implementedFile = '$baseDir\\implemented_apis.md';
  final outputFile = '$baseDir\\api_audit_report.md';

  print('Loading Swagger from $swaggerFile...');
  final swaggerEps = await loadSwaggerEndpoints(swaggerFile);
  
  print('Loading Implemented APIs from $implementedFile...');
  final implementedEps = await loadImplementedEndpoints(implementedFile);

  print('Generating report...');
  generateReport(swaggerEps, implementedEps, outputFile);
}
