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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primaryNavy),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryGold,
                    child: Icon(Icons.person, size: 40, color: AppColors.primaryNavy),
                  ),
                  SizedBox(height: 10),
                  Text('Shri Nrityalaya', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: AppColors.warning),
              title: const Text('Fee Management'),
              onTap: () {
                Navigator.pop(context); // close drawer
                GoRouter.of(context).push('/fees');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: AppColors.primaryNavy),
              title: const Text('Manage Students'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/students');
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: AppColors.primaryNavy),
              title: const Text('Practice Submissions'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/learning');
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: AppColors.primaryGold),
              title: const Text('Student Progress'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/progress');
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign, color: AppColors.error),
              title: const Text('Messages'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/messaging');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: AppColors.success),
              title: const Text('Academy Events'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/events');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Profile & Settings'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/profile');
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
