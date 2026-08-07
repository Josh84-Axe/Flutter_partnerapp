import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../services/pwa_service.dart';

void showPwaInstallInstructions(BuildContext context) {
  final pwa = PwaService();
  final bool isIOS = pwa.isIOS;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isIOS ? Icons.apple : Icons.install_mobile,
                    size: 32,
                    color: isIOS ? Colors.blue : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    (isIOS ? 'ios_install_title' : 'pwa_generic_title').tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            (isIOS ? 'ios_install_subtitle' : 'pwa_generic_subtitle').tr(),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          if (isIOS) ...[
            _buildInstallStep(
              context,
              number: '1',
              text: 'pwa_ios_step_1'.tr(),
              icon: Icons.ios_share,
            ),
            const SizedBox(height: 20),
            _buildInstallStep(
              context,
              number: '2',
              text: 'pwa_ios_step_2'.tr(),
              icon: Icons.add_box_outlined,
            ),
            const SizedBox(height: 20),
            _buildInstallStep(
              context,
              number: '3',
              text: 'pwa_ios_step_3'.tr(),
              icon: Icons.add,
            ),
          ] else ...[
            _buildInstallStep(
              context,
              number: '1',
              text: 'pwa_android_step_1'.tr(),
              icon: Icons.more_vert,
            ),
            const SizedBox(height: 20),
            _buildInstallStep(
              context,
              number: '2',
              text: 'pwa_android_step_2'.tr(),
              icon: Icons.install_mobile,
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('ok'.tr()),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildInstallStep(
  BuildContext context, {
  required String number,
  required String text,
  required IconData icon,
}) {
  return Row(
    children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Icon(icon, color: Colors.grey.shade700, size: 24),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );
}
