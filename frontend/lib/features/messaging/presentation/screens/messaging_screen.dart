import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages & Announcements')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMessageCard('Important: Studio Closed Tomorrow', 'Admin', '10:00 AM', true, true),
          _buildMessageCard('Feedback on your recent submission', 'Teacher Radhika', 'Yesterday', false, false),
          _buildMessageCard('Costume measurements due', 'Admin', 'Mon', true, false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryGold,
        child: const Icon(Icons.edit, color: AppColors.deepNavy),
      ),
    );
  }

  Widget _buildMessageCard(String subject, String sender, String time, bool isAnnouncement, bool isUnread) {
    return Card(
      color: isUnread ? Colors.blue.withValues(alpha: 0.05) : null,
      child: ListTile(
        leading: Icon(isAnnouncement ? Icons.campaign : Icons.mail, 
            color: isAnnouncement ? AppColors.warning : AppColors.primaryNavy),
        title: Text(subject, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text('From: $sender'),
        trailing: Text(time, style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
        onTap: () {},
      ),
    );
  }
}
