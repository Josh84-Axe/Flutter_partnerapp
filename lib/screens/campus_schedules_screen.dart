import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/campus_provider.dart';

class CampusSchedulesScreen extends StatelessWidget {
  const CampusSchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CampusProvider>();
    final schedules = provider.schedules;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Schedules'),
      ),
      body: provider.isLoading && schedules.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.loadData(),
              child: schedules.isEmpty
                  ? ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: Text('No schedules found.')),
                        )
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        final isActive = schedule.isCurrentlyActive;

                        return Card(
                          elevation: isActive ? 4 : 1,
                          color: isActive ? colorScheme.primaryContainer : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: isActive
                                ? BorderSide(color: colorScheme.primary, width: 2)
                                : BorderSide.none,
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isActive ? Icons.schedule : Icons.history_toggle_off,
                                      color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        schedule.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isActive ? colorScheme.onPrimaryContainer : null,
                                        ),
                                      ),
                                    ),
                                    if (isActive)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'ACTIVE NOW',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text('${schedule.startTime} - ${schedule.endTime}'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (schedule.prioritizedPortals.isNotEmpty) ...[
                                  Text('Prioritized:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.secondary)),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: schedule.prioritizedPortals
                                        .map((p) => Chip(
                                              label: Text(p, style: const TextStyle(fontSize: 11)),
                                              visualDensity: VisualDensity.compact,
                                            ))
                                        .toList(),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (schedule.restrictedCategories.isNotEmpty) ...[
                                  Text('Restricted:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.error)),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: schedule.restrictedCategories
                                        .map((r) => Chip(
                                              label: Text(r, style: const TextStyle(fontSize: 11)),
                                              visualDensity: VisualDensity.compact,
                                              backgroundColor: colorScheme.errorContainer,
                                              labelStyle: TextStyle(color: colorScheme.onErrorContainer),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
