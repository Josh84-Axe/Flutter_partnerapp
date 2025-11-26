import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'dart:async';

class SubscriptionPlanCard extends StatefulWidget {
  final String planName;
  final DateTime renewalDate;
  final bool isLoading;

  const SubscriptionPlanCard({
    super.key,
    required this.planName,
    required this.renewalDate,
    this.isLoading = false,
  });

  @override
  State<SubscriptionPlanCard> createState() => _SubscriptionPlanCardState();
}

class _SubscriptionPlanCardState extends State<SubscriptionPlanCard> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    if (widget.renewalDate.isAfter(now)) {
      setState(() {
        _timeLeft = widget.renewalDate.difference(now);
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
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
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
                      color: _timeLeft.inDays < 3 
                          ? colorScheme.errorContainer 
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: _timeLeft.inDays < 3 
                              ? colorScheme.onErrorContainer 
                              : colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatTimeLeft(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _timeLeft.inDays < 3 
                                ? colorScheme.onErrorContainer 
                                : colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'renews'.tr(namedArgs: {
                      'date': DateFormat('MMM d, yyyy').format(widget.renewalDate)
                    }),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.wifi,
                size: 32,
                color: colorScheme.onPrimaryContainer,
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
