import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen to display legal documents (Privacy Policy, Terms of Service)
class LegalDocumentScreen extends StatefulWidget {
  final String documentType; // 'privacy' or 'terms'
  
  const LegalDocumentScreen({
    super.key,
    required this.documentType,
  });

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  String _content = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get current locale
      final String locale = context.locale.languageCode;
      
      // Determine which document to load based on type and locale
      final String documentName = widget.documentType == 'privacy'
          ? 'privacy_policy'
          : 'terms_of_service';
      
      // Try to load document in current locale, fallback to English
      String assetPath = 'assets/legal/${documentName}_$locale.md';
      
      String content;
      try {
        content = await rootBundle.loadString(assetPath);
      } catch (e) {
        // Fallback to English if locale version doesn't exist
        assetPath = 'assets/legal/${documentName}_en.md';
        content = await rootBundle.loadString(assetPath);
      }
      
      if (mounted) {
        setState(() {
          _content = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'failed_to_load_document'.tr();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Determine title based on document type
    final String title = widget.documentType == 'privacy'
        ? 'privacy_policy'.tr()
        : 'terms_of_service'.tr();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocument,
            tooltip: 'refresh'.tr(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadDocument,
                          icon: const Icon(Icons.refresh),
                          label: Text('retry'.tr()),
                        ),
                      ],
                    ),
                  ),
                )
              : Markdown(
                  data: _content,
                  selectable: true,
                  onTapLink: (text, href, title) async {
                    if (href != null) {
                      final uri = Uri.parse(href);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    }
                  },
                  styleSheet: MarkdownStyleSheet(
                    h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                    h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                    h3: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                    listBullet: Theme.of(context).textTheme.bodyMedium,
                    strong: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    em: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                    a: TextStyle(
                      color: colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                    blockquote: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                    blockquoteDecoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border(
                        left: BorderSide(
                          color: colorScheme.primary,
                          width: 4,
                        ),
                      ),
                    ),
                    blockquotePadding: const EdgeInsets.all(12),
                    code: TextStyle(
                      backgroundColor: Colors.grey.shade100,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
    );
  }
}
