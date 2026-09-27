import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/reminder.dart';
import '../providers/reminders_provider.dart';
import '../providers/reminder_resolvers.dart';
import '../widgets/reminder_tile.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  ReminderType? _activeFilter;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RemindersProvider>();
      if (provider.reminders.isEmpty) {
        provider.fetchReminders();
      }
      provider.runAutoResolution();
    });
  }

  Future<void> _onReminderTap(
    BuildContext context,
    RemindersProvider provider,
    Reminder reminder,
  ) async {
    switch (reminder.type) {
      case ReminderType.appointment:
        final appointmentId = reminder.appointmentId;
        if (appointmentId == null || appointmentId.isEmpty) {
          context.go('/appointments');
          return;
        }

        context.push('/appointments/detail/$appointmentId');
        return;
      case ReminderType.foodLog:
        final result = await context.push<bool>(
          '/food-log/entry?title=${Uri.encodeQueryComponent(reminder.title)}',
        );
        if (result == true && context.mounted) {
          provider.resolveReminder(
            reminderId: reminder.id,
            event: ReminderResolutionEvent(
              action: 'food_logged',
              occurredAt: DateTime.now(),
            ),
          );
        }
        return;
      case ReminderType.medication:
        await _showMedicationEditDialog(context, provider, reminder);
        return;
    }
  }

  Future<void> _showMedicationEditDialog(
    BuildContext context,
    RemindersProvider provider,
    Reminder reminder,
  ) async {
    final time = TimeOfDay.fromDateTime(reminder.dueAt);
    TimeOfDay selectedTime = time;
    ReminderFrequency selectedFrequency = reminder.frequency;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Edit Medication Reminder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Time'),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.schedule),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setModalState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ReminderFrequency>(
                    initialValue: selectedFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: ReminderFrequency.values
                        .map(
                          (f) =>
                              DropdownMenuItem(value: f, child: Text(f.label)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          selectedFrequency = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    provider.deleteMedicationReminder(reminder.id);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final updatedDueAt = DateTime(
                      reminder.dueAt.year,
                      reminder.dueAt.month,
                      reminder.dueAt.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    provider.updateMedicationReminder(
                      reminderId: reminder.id,
                      dueAt: updatedDueAt,
                      frequency: selectedFrequency,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showMedicationCreateDialog(
    BuildContext context,
    RemindersProvider provider,
  ) async {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    ReminderFrequency selectedFrequency = ReminderFrequency.daily;
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Add Medication Reminder'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Medication',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Instruction',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<ReminderFrequency>(
                      initialValue: selectedFrequency,
                      decoration: const InputDecoration(
                        labelText: 'Frequency',
                        border: OutlineInputBorder(),
                      ),
                      items: ReminderFrequency.values
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(f.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setModalState(() {
                            selectedFrequency = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Time'),
                      subtitle: Text(selectedTime.format(context)),
                      trailing: const Icon(Icons.schedule),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      return;
                    }

                    final now = DateTime.now();
                    final dueAt = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    provider.addMedicationReminder(
                      title: titleController.text.trim(),
                      subtitle: subtitleController.text.trim().isEmpty
                          ? 'Medication reminder'
                          : subtitleController.text.trim(),
                      dueAt: dueAt,
                      frequency: selectedFrequency,
                      category: ReminderCategory.high,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RemindersProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final activeGroups = provider.activeGroupedByTiming(
          filter: _activeFilter,
        );
        final history = provider.historyReminders(filter: _activeFilter);
        final filterTypes = provider.availableFilterTypes();
        final hasMedicationFilter =
            _activeFilter == null || _activeFilter == ReminderType.medication;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            const Text(
              'Reminders',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track all pending and resolved reminders by type.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            _TypeFilterChips(
              activeFilter: _activeFilter,
              types: filterTypes,
              onChanged: (type) {
                setState(() {
                  _activeFilter = type;
                });
              },
            ),
            const SizedBox(height: 16),
            if (hasMedicationFilter)
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () =>
                      _showMedicationCreateDialog(context, provider),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Medication Reminder'),
                ),
              ),
            if (hasMedicationFilter) const SizedBox(height: 12),
            ..._timingSectionsOrder.map((timingState) {
              final reminders = activeGroups[timingState] ?? const <Reminder>[];
              if (reminders.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _timingHeader(timingState),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...reminders.map(
                    (reminder) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ReminderTile(
                        reminder: reminder,
                        onTap: () =>
                            _onReminderTap(context, provider, reminder),
                        footer: _ReminderActions(
                          reminder: reminder,
                          canSnooze: provider.canSnooze(reminder.id),
                          onPrimaryTap: () =>
                              _onReminderTap(context, provider, reminder),
                          onSnoozeTap: () {
                            final success = provider.snoozeReminder(
                              reminderId: reminder.id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Reminder snoozed by 30 minutes.'
                                      : 'Snooze already used for this reminder.',
                                ),
                              ),
                            );
                          },
                          onMedicationDeleteTap:
                              reminder.type == ReminderType.medication
                              ? () {
                                  provider.deleteMedicationReminder(
                                    reminder.id,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Medication reminder deleted.',
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              );
            }),
            if (activeGroups.values.every((list) => list.isEmpty))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No active reminders for this filter.'),
              ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                setState(() {
                  _showHistory = !_showHistory;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      'Completed / Missed History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('(${history.length})'),
                    const Spacer(),
                    Icon(_showHistory ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
              ),
            ),
            if (_showHistory) ...[
              if (history.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('No completed or missed reminders yet.'),
                )
              else
                ...history.map(
                  (reminder) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ReminderTile(reminder: reminder),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  String _timingHeader(ReminderTimingState state) {
    switch (state) {
      case ReminderTimingState.overdue:
        return 'Overdue';
      case ReminderTimingState.due:
        return 'Due';
      case ReminderTimingState.upcoming:
        return 'Upcoming';
    }
  }

  static const List<ReminderTimingState> _timingSectionsOrder = [
    ReminderTimingState.overdue,
    ReminderTimingState.due,
    ReminderTimingState.upcoming,
  ];
}

class _TypeFilterChips extends StatelessWidget {
  final ReminderType? activeFilter;
  final List<ReminderType> types;
  final ValueChanged<ReminderType?> onChanged;

  const _TypeFilterChips({
    required this.activeFilter,
    required this.types,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: activeFilter == null,
          onSelected: (_) => onChanged(null),
        ),
        ...types.map(
          (type) => ChoiceChip(
            label: Text(_label(type)),
            selected: activeFilter == type,
            onSelected: (_) => onChanged(type),
          ),
        ),
      ],
    );
  }

  String _label(ReminderType type) {
    switch (type) {
      case ReminderType.appointment:
        return 'Appointments';
      case ReminderType.foodLog:
        return 'Food log';
      case ReminderType.medication:
        return 'Medication';
    }
  }
}

class _ReminderActions extends StatelessWidget {
  final Reminder reminder;
  final bool canSnooze;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSnoozeTap;
  final VoidCallback? onMedicationDeleteTap;

  const _ReminderActions({
    required this.reminder,
    required this.canSnooze,
    required this.onPrimaryTap,
    required this.onSnoozeTap,
    this.onMedicationDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasDelete =
        reminder.type == ReminderType.medication &&
        onMedicationDeleteTap != null;

    return Row(
      children: [
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              backgroundColor: const Color(0xFFE5E0FF),
              foregroundColor: const Color(0xFF4B3EA5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onPrimaryTap,
            child: Text(_primaryActionLabel(reminder.type)),
          ),
        ),
        const SizedBox(width: 10),
        if (hasDelete)
          Container(
            width: 52,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD8D2F1)),
            ),
            child: IconButton(
              onPressed: onMedicationDeleteTap,
              tooltip: 'Delete reminder',
              icon: const Icon(Icons.delete_outline_rounded),
              color: const Color(0xFFC62828),
            ),
          ),
        if (!hasDelete)
          SizedBox(
            width: 108,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                foregroundColor: const Color(0xFF4B3EA5),
                side: const BorderSide(color: Color(0xFF7B70C9), width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              onPressed: canSnooze ? onSnoozeTap : null,
              icon: const Icon(Icons.snooze_outlined),
              label: const Text('+30m'),
            ),
          ),
      ],
    );
  }

  String _primaryActionLabel(ReminderType type) {
    switch (type) {
      case ReminderType.appointment:
        return 'Manage appointment';
      case ReminderType.foodLog:
        return 'Log now';
      case ReminderType.medication:
        return 'Edit medication';
    }
  }
}
