import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Parent!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stay updated with your child\'s progress.',
              style: TextStyle(fontSize: 16, color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            _buildActionCard(
              context,
              'Fee Status & Payments',
              'View obligations and upload proof',
              Icons.receipt_long,
              AppColors.primaryNavy,
              '/fees',
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Student Progress',
              'Track learning milestones',
              Icons.trending_up,
              AppColors.primaryGold,
              '/progress',
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Announcements',
              'View academy messages',
              Icons.campaign,
              AppColors.error,
              '/messaging',
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              'Academy Events',
              'View upcoming performances',
              Icons.event,
              AppColors.success,
              '/events',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String route) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 14, color: AppColors.mutedText),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.mutedText, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
