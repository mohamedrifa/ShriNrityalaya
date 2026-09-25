import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/api_client.dart' as shri_nrityalaya_app_dio;
import '../../../auth/presentation/providers/auth_providers.dart' as shri_nrityalaya_app_auth;

final announcementsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.read(shri_nrityalaya_app_dio.dioProvider);
  final response = await dio.get('/announcements');
  return response.data['data'];
});

class MessagingScreen extends ConsumerWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsState = ref.watch(announcementsProvider);
    final userRole = ref.watch(shri_nrityalaya_app_auth.authProvider).userRole;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages & Announcements')),
      body: announcementsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (announcements) {
          if (announcements.isEmpty) {
            return const Center(child: Text('No announcements yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final ann = announcements[index];
              return _buildMessageCard(
                ann['title'] ?? 'No Title',
                ann['content'] ?? '',
                'Teacher / Admin',
                true,
                false,
              );
            },
          );
        },
      ),
      floatingActionButton: (userRole == 'Teacher' || userRole == 'SystemAdmin')
          ? FloatingActionButton.extended(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => const _CreateAnnouncementSheet(),
                );
              },
              backgroundColor: AppColors.primaryGold,
              icon: const Icon(Icons.add, color: AppColors.deepNavy),
              label: const Text('New', style: TextStyle(color: AppColors.deepNavy, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildMessageCard(String subject, String content, String sender, bool isAnnouncement, bool isUnread) {
    return Card(
      color: isUnread ? Colors.blue.withValues(alpha: 0.05) : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isAnnouncement ? Icons.campaign : Icons.mail, color: isAnnouncement ? AppColors.warning : AppColors.primaryNavy),
                const SizedBox(width: 8),
                Expanded(child: Text(subject, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ],
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(color: AppColors.mutedText)),
            const SizedBox(height: 12),
            Text('From: $sender', style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _CreateAnnouncementSheet extends ConsumerStatefulWidget {
  const _CreateAnnouncementSheet();

  @override
  ConsumerState<_CreateAnnouncementSheet> createState() => _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState extends ConsumerState<_CreateAnnouncementSheet> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _post() async {
    if (_titleCtrl.text.isEmpty || _contentCtrl.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final dio = ref.read(shri_nrityalaya_app_dio.dioProvider);
      await dio.post('/announcements', data: {
        'title': _titleCtrl.text,
        'content': _contentCtrl.text,
      });
      ref.invalidate(announcementsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New Announcement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentCtrl,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Message Content', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: AppColors.primaryNavy),
              onPressed: _isLoading ? null : _post,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Post Announcement'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
