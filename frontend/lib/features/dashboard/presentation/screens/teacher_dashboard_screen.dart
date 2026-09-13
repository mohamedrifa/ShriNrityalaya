import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () {
            GoRouter.of(context).push('/profile');
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Action Required',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              'Pending Payment Reviews',
              '3 proofs await your approval',
              Icons.receipt_long,
              AppColors.warning,
              '/fees',
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Manage Students',
              'Add, Edit, Remove profiles',
              Icons.people,
              AppColors.primaryNavy,
              '/students',
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Practice Submissions',
              '5 new videos need feedback',
              Icons.video_library,
              AppColors.primaryNavy,
              '/learning',
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Student Progress',
              'Update skills & certificates',
              Icons.trending_up,
              AppColors.primaryGold,
              '/progress',
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Messages & Announcements',
              'Send broadcast messages',
              Icons.campaign,
              AppColors.error,
              '/messaging',
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Academy Events',
              'Manage upcoming events',
              Icons.event,
              AppColors.success,
              '/events',
            ),
            const SizedBox(height: 24),
            Text(
              "Today's Classes",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildClassCard(context, 'Beginners Batch', '16:00 - 17:00', '15 Students'),
            const SizedBox(height: 12),
            _buildClassCard(context, 'Intermediate Batch', '17:30 - 19:00', '12 Students'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryGold,
        child: const Icon(Icons.add, color: AppColors.deepNavy),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String route) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (route.isNotEmpty) {
            GoRouter.of(context).push(route);
          }
        },
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, String name, String time, String students) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Scheduled', style: TextStyle(color: AppColors.success, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: AppColors.mutedText),
                const SizedBox(width: 8),
                Text(time, style: const TextStyle(color: AppColors.mutedText)),
                const SizedBox(width: 16),
                const Icon(Icons.people, size: 16, color: AppColors.mutedText),
                const SizedBox(width: 8),
                Text(students, style: const TextStyle(color: AppColors.mutedText)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  GoRouter.of(context).push('/attendance');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryNavy,
                  side: const BorderSide(color: AppColors.primaryNavy),
                ),
                child: const Text('Mark Attendance'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
