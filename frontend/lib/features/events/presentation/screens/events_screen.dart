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
                                  // Simplified registration with hardcoded student ID for demo
                                  await ref.read(eventRepositoryProvider).registerForEvent(e.id!, '00000000-0000-0000-0000-000000000000');
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registered successfully!')));
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $error')));
                                }
                              },
                              child: const Text('Register Now'),
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
        onPressed: () => _showAddEventDialog(context, ref),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Event', style: TextStyle(color: Colors.white)),
      ) : null,
    );
  }

  void _showAddEventDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final feeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Event'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
                TextFormField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
                TextFormField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location')),
                TextFormField(controller: feeCtrl, decoration: const InputDecoration(labelText: 'Participation Fee'), keyboardType: TextInputType.number),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newEvent = AcademyEvent(
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  eventDate: DateTime.now().add(const Duration(days: 30)), // Mock future date
                  location: locCtrl.text.trim(),
                  participationFee: double.tryParse(feeCtrl.text),
                  status: 'Upcoming',
                );
                await ref.read(eventsProvider.notifier).createEvent(newEvent);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
