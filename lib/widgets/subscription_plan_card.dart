import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'skeleton_loader.dart';

import 'dart:async';

class SubscriptionPlanCard extends StatefulWidget {
  final String planName;
  final DateTime? renewalDate;
  final bool isLoading;
  final bool isInGracePeriod;
  final int graceDaysRemaining;
  final bool isExpired;

  const SubscriptionPlanCard({
    super.key,
    required this.planName,
    this.renewalDate,
    this.isLoading = false,
    this.isInGracePeriod = false,
    this.graceDaysRemaining = 0,
    this.isExpired = false,
  });

  @override
  State<SubscriptionPlanCard> createState() => _SubscriptionPlanCardState();
}

class _SubscriptionPlanCardState extends State<SubscriptionPlanCard> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    if (widget.renewalDate == null) return;
    
    final now = DateTime.now();
    if (widget.renewalDate!.isAfter(now)) {
      setState(() {
        _timeLeft = widget.renewalDate!.difference(now);
      });
    } else {
      setState(() {
        _timeLeft = Duration.zero;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLifetime = widget.renewalDate == null;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: widget.isLoading 
          ? const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonText(width: 100),
                    SizedBox(height: 12),
                    SkeletonText(width: 150, height: 24),
                    SizedBox(height: 12),
                    SkeletonLoader(width: 120, height: 28, borderRadius: BorderRadius.all(Radius.circular(20))),
                  ],
                ),
              ),
              SkeletonLoader(width: 64, height: 64, borderRadius: BorderRadius.all(Radius.circular(16))),
            ],
          )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'subscription_plan'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.planName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.isInGracePeriod
                              ? Colors.orange.shade100
                              : (widget.isExpired
                                  ? Colors.red.shade100
                                  : (isLifetime 
                                      ? colorScheme.primaryContainer 
                                      : (_timeLeft.inDays < 3 
                                          ? colorScheme.errorContainer 
                                          : colorScheme.primaryContainer))),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.isInGracePeriod
                                  ? Icons.hourglass_top
                                  : (widget.isExpired
                                      ? Icons.lock_outline
                                      : (isLifetime ? Icons.all_inclusive : Icons.timer_outlined)),
                              size: 16,
                              color: widget.isInGracePeriod
                                  ? Colors.orange.shade900
                                  : (widget.isExpired
                                      ? Colors.red.shade900
                                      : (isLifetime 
                                          ? colorScheme.onPrimaryContainer
                                          : (_timeLeft.inDays < 3 
                                              ? colorScheme.onErrorContainer 
                                              : colorScheme.onPrimaryContainer))),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.isInGracePeriod
                                  ? 'Période de grâce (${widget.graceDaysRemaining}j)'
                                  : (widget.isExpired
                                      ? 'Abonnement expiré'
                                      : (isLifetime ? 'lifetime'.tr() : _formatTimeLeft())),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: widget.isInGracePeriod
                                    ? Colors.orange.shade900
                                    : (widget.isExpired
                                        ? Colors.red.shade900
                                        : (isLifetime 
                                            ? colorScheme.onPrimaryContainer
                                            : (_timeLeft.inDays < 3 
                                                ? colorScheme.onErrorContainer 
                                                : colorScheme.onPrimaryContainer))),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!isLifetime)
                        Text(
                          widget.isInGracePeriod
                              ? 'Expiré — Coupure dans ${widget.graceDaysRemaining} jour(s)'
                              : (widget.isExpired
                                  ? 'Accès suspendu — Renouvelez pour débloquer'
                                  : 'renews'.tr(namedArgs: {
                                      'date': DateFormat('MMM d, yyyy').format(widget.renewalDate!)
                                    })),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.isInGracePeriod
                                ? Colors.orange.shade900
                                : (widget.isExpired ? Colors.red.shade900 : colorScheme.onSurfaceVariant),
                            fontWeight: (widget.isInGracePeriod || widget.isExpired) ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/subscription-plans'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.isInGracePeriod
                          ? Colors.orange.shade600
                          : (widget.isExpired ? Colors.red.shade600 : colorScheme.primaryContainer),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.isInGracePeriod
                          ? Icons.payment
                          : (widget.isExpired ? Icons.lock_open : Icons.wifi),
                      size: 32,
                      color: (widget.isInGracePeriod || widget.isExpired)
                          ? Colors.white
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  String _formatTimeLeft() {
    if (_timeLeft.inDays > 0) {
      return 'days_left'.tr(namedArgs: {'count': _timeLeft.inDays.toString()});
    } else if (_timeLeft.inHours > 0) {
      return 'hours_left'.tr(namedArgs: {'count': _timeLeft.inHours.toString()});
    } else if (_timeLeft.inMinutes > 0) {
      return 'mins_left'.tr(namedArgs: {'count': _timeLeft.inMinutes.toString()});
    } else {
      return 'expired'.tr();
    }
  }
}
