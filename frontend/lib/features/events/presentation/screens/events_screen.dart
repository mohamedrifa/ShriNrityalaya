import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:shri_nrityalaya_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:shri_nrityalaya_app/features/events/presentation/providers/event_providers.dart';
import 'package:shri_nrityalaya_app/features/events/domain/models/academy_event.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(eventsProvider);
    final userRole = ref.watch(authProvider).userRole;
    final isTeacher = userRole == 'Teacher' || userRole == 'SystemAdmin';

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Arangetram & Events'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: eventsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (events) {
          if (events.isEmpty) return const Center(child: Text('No upcoming events.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final e = events[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryNavy)),
                      const SizedBox(height: 4),
                      Text('${e.eventDate.day}/${e.eventDate.month}/${e.eventDate.year} @ ${e.location}', style: const TextStyle(color: AppColors.mutedText)),
                      const SizedBox(height: 8),
                      Text(e.description),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fee: ${e.participationFee == null || e.participationFee == 0 ? 'Free' : '\$${e.participationFee}'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (!isTeacher)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: AppColors.primaryNavy),
                              onPressed: () async {
                                try {
                                  await ref.read(eventRepositoryProvider).registerForEvent(e.id!, '00000000-0000-0000-0000-000000000000');
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registered successfully!')));
                                } catch (error) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $error')));
                                }
                              },
                              child: const Text('Register Now'),
                            ),
                          if (isTeacher)
                            TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => _EventDialog(event: e),
                                );
                              },
                              icon: const Icon(Icons.edit, color: AppColors.primaryNavy),
                              label: const Text('Edit', style: TextStyle(color: AppColors.primaryNavy)),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isTeacher ? FloatingActionButton.extended(
        backgroundColor: AppColors.primaryNavy,
        onPressed: () {
          showDialog(context: context, builder: (ctx) => const _EventDialog());
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Event', style: TextStyle(color: Colors.white)),
      ) : null,
    );
  }
}

class _EventDialog extends ConsumerStatefulWidget {
  final AcademyEvent? event;
  const _EventDialog({Key? key, this.event}) : super(key: key);

  @override
  ConsumerState<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends ConsumerState<_EventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locCtrl;
  late TextEditingController _feeCtrl;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.event?.title ?? '');
    _descCtrl = TextEditingController(text: widget.event?.description ?? '');
    _locCtrl = TextEditingController(text: widget.event?.location ?? '');
    _feeCtrl = TextEditingController(text: widget.event?.participationFee?.toString() ?? '');
    if (widget.event != null) {
      _selectedDate = widget.event!.eventDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.event != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Event' : 'Create Event'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              TextFormField(controller: _locCtrl, decoration: const InputDecoration(labelText: 'Location')),
              TextFormField(controller: _feeCtrl, decoration: const InputDecoration(labelText: 'Participation Fee'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  ),
                  TextButton(onPressed: _pickDate, child: const Text('Change Date')),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (isEdit) {
                final updated = AcademyEvent(
                  id: widget.event!.id,
                  title: _titleCtrl.text.trim(),
                  description: _descCtrl.text.trim(),
                  eventDate: _selectedDate,
                  location: _locCtrl.text.trim(),
                  participationFee: double.tryParse(_feeCtrl.text),
                  status: widget.event!.status,
                );
                await ref.read(eventsProvider.notifier).updateEvent(updated);
              } else {
                final newEvent = AcademyEvent(
                  title: _titleCtrl.text.trim(),
                  description: _descCtrl.text.trim(),
                  eventDate: _selectedDate,
                  location: _locCtrl.text.trim(),
                  participationFee: double.tryParse(_feeCtrl.text),
                  status: 'Upcoming',
                );
                await ref.read(eventsProvider.notifier).createEvent(newEvent);
              }
              // ignore: use_build_context_synchronously
              if (mounted) Navigator.pop(context);
            }
          },
          child: Text(isEdit ? 'Save Changes' : 'Create'),
        ),
      ],
    );
  }
}
