import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../fees/presentation/providers/fee_obligations_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/network/api_client.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentsState = ref.watch(studentAssessmentsProvider('me'));
    final feesState = ref.watch(feeObligationsProvider);
    final profileState = ref.watch(profileProvider);
    final baseUrl = ref.read(dioProvider).options.baseUrl.replaceAll('/api/v1', '');

    String username = 'Parent';
    String? imageUrl;
    profileState.whenData((profile) {
      username = profile['firstName'] ?? profile['userName'] ?? 'Parent';
      if (username.isEmpty) username = 'Parent';
      imageUrl = profile['profilePictureUrl'] as String?;
    });

    Widget profileAvatar = CircleAvatar(
      backgroundColor: AppColors.primaryGold,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage('$baseUrl$imageUrl') : null,
      child: imageUrl == null || imageUrl!.isEmpty ? const Icon(Icons.person, color: AppColors.primaryNavy) : null,
    );

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(
            icon: profileAvatar,
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primaryNavy),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: profileAvatar,
                  ),
                  const SizedBox(height: 10),
                  const Text('Parent Menu', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: AppColors.warning),
              title: const Text('Fee Management'),
              onTap: () {
                Navigator.pop(context);
                context.push('/fees');
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: AppColors.primaryGold),
              title: const Text('Student Progress'),
              onTap: () {
                Navigator.pop(context);
                context.push('/progress');
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign, color: AppColors.error),
              title: const Text('Announcements'),
              onTap: () {
                Navigator.pop(context);
                context.push('/messaging');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: AppColors.success),
              title: const Text('Academy Events'),
              onTap: () {
                Navigator.pop(context);
                context.push('/events');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome $username!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stay updated with your child\'s progress.',
              style: TextStyle(fontSize: 16, color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            
            // Dynamic Unpaid Fees Alert
            feesState.when(
              data: (obligations) {
                final unpaid = obligations.where((o) => o.status == 'Unpaid').toList();
                if (unpaid.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    Card(
                      color: AppColors.error.withValues(alpha: 0.1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.error)),
                      child: InkWell(
                        onTap: () => context.push('/fees'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 30),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Fee Due', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 16)),
                                    Text('You have ${unpaid.length} pending fee obligation(s). Tap to view.', style: const TextStyle(color: AppColors.error)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Dynamic Child Progress Summary
            assessmentsState.when(
              data: (assessments) {
                if (assessments.isEmpty) return const SizedBox.shrink();
                final latest = assessments.first;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                        TextButton(onPressed: () => context.push('/progress'), child: const Text('View Report')),
                      ],
                    ),
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: AppColors.primaryGold, child: Icon(Icons.star, color: Colors.white)),
                        title: Text('${latest.skillName.isNotEmpty ? latest.skillName : 'Skill Assessment'} - ${latest.skillLevel}'),
                        subtitle: Text('Score: ${latest.score} - Assessed on ${latest.assessmentDate.toLocal().toString().split(' ')[0]}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => context.push('/progress'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Upcoming Events (Static for now as before)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upcoming Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                TextButton(onPressed: () => context.push('/events'), child: const Text('View All')),
              ],
            ),
            Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: AppColors.success, child: Icon(Icons.event, color: Colors.white)),
                title: const Text('Annual Arangetram Showcase'),
                subtitle: const Text('Next Month - Don\'t forget to register!'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/events'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

