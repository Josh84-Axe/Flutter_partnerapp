import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/voucher_model.dart';
import '../models/plan_model.dart';

class VoucherTicketCard extends StatefulWidget {
  final VoucherModel voucher;
  final PlanModel? plan;
  final Function(String message) onMessage;

  const VoucherTicketCard({
    super.key,
    required this.voucher,
    this.plan,
    required this.onMessage,
  });

  @override
  State<VoucherTicketCard> createState() => _VoucherTicketCardState();
}

class _VoucherTicketCardState extends State<VoucherTicketCard> {
  bool _isCopied = false;

  void _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.voucher.code));
    setState(() => _isCopied = true);
    widget.onMessage('Code copied: ${widget.voucher.code}');
    
    // Reset copy state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  Color _getStatusColor() {
    if (widget.voucher.isUsed) return Colors.orange;
    if (widget.voucher.isExpired) return Colors.red;
    if (widget.voucher.isAssigned) return Colors.blue; 
    return Colors.green;
  }

  String _getStatusText() {
    if (widget.voucher.isUsed) return 'USED';
    if (widget.voucher.isExpired) return 'EXPIRED';
    if (widget.voucher.isAssigned) return 'ASSIGNED';
    return 'ACTIVE';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final theme = Theme.of(context);
    final isUsed = widget.voucher.isUsed;

    return GestureDetector(
      onTap: _handleCopy,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Left Status Strip
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 8,
              child: Container(color: statusColor),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Plan Name & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.plan?.name ?? widget.voucher.planName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          _getStatusText(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Middle Row: Code (Most Prominent)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                        style: BorderStyle.none, // Make looks cleaner
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.voucher.code,
                          style: TextStyle(
                            fontFamily: 'Courier', // Monospace for code
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Icon(
                          _isCopied ? Icons.check_circle : Icons.copy,
                          size: 20,
                          color: _isCopied ? Colors.green : theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bottom Section: Features (Shelved 'Used By' for now as per user request)
                  /* if (isUsed && widget.voucher.usedBy != null) ...[
                    const Divider(),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                         Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Used By',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                              Text(
                                widget.voucher.usedBy!,
                                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (widget.voucher.usedAt != null)
                          Text(
                            DateFormat('MM/dd HH:mm').format(widget.voucher.usedAt!),
                            style: theme.textTheme.labelSmall,
                          ),
                      ],
                    ),
                  ] else */ if (widget.plan != null) ...[
                    Row(
                      children: [
                        if (widget.plan?.dataLimit != null)
                          _FeatureBadge(icon: Icons.cloud_download, label: '${widget.plan!.dataLimit! ~/ 1024} GB'), // Assuming MB
                        const SizedBox(width: 8),
                        if (widget.plan?.sharedUsersLabel != null) // changed from deviceLimit
                          _FeatureBadge(icon: Icons.devices, label: widget.plan!.sharedUsersLabel),
                        const SizedBox(width: 8),
                        if (widget.plan?.formattedValidity != null) // changed from validity
                          _FeatureBadge(icon: Icons.timer, label: widget.plan!.formattedValidity),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Watermark Overlay
            if (_isCopied)
              Positioned(
                right: 20,
                bottom: 20,
                child: Transform.rotate(
                  angle: -0.2, // Tilted stamp
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green.withOpacity(0.4), width: 4),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: const Text(
                      'COPIED',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
