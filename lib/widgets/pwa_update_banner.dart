import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/pwa_service.dart';
import '../flavors.dart';

class PwaUpdateBanner extends StatefulWidget {
  const PwaUpdateBanner({super.key});

  @override
  State<PwaUpdateBanner> createState() => _PwaUpdateBannerState();
}

class _PwaUpdateBannerState extends State<PwaUpdateBanner> {
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkPostUpdateToast();
      });
    }
  }

  void _checkPostUpdateToast() {
    final pwa = PwaService();
    if (pwa.checkPostUpdateToast() && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'app_updated_success'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String _getReadyMessage() {
    switch (F.name) {
      case 'campus':
        return 'update_campus_ready'.tr();
      case 'partner':
        return 'update_partner_ready'.tr();
      case 'family':
      default:
        return 'update_family_ready'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const SizedBox.shrink();

    final pwa = PwaService();

    return StreamBuilder<bool>(
      stream: pwa.updateAvailableStream,
      initialData: pwa.isUpdateAvailable,
      builder: (context, snapshot) {
        final bool isUpdate = snapshot.data ?? pwa.isUpdateAvailable;
        if (!isUpdate) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade800, Colors.orange.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.shade900.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.system_update_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'update_available'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getReadyMessage(),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isApplying
                    ? null
                    : () async {
                        setState(() => _isApplying = true);
                        await pwa.applyUpdate();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.amber.shade900,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isApplying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
                      )
                    : Text(
                        'update_now'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
