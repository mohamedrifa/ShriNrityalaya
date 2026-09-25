import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/directory_providers.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  String _searchQuery = '';

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final directoryState = ref.watch(directoryProvider);

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Student & Parent Directory'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Student or Parent Name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: directoryState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (directory) {
                final filtered = directory.where((entry) {
                  final studentName = '${entry['studentFirstName']} ${entry['studentLastName']}'.toLowerCase();
                  final parentName = '${entry['parentFirstName']} ${entry['parentLastName']}'.toLowerCase();
                  return studentName.contains(_searchQuery) || parentName.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No matching records found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    final studentName = '${entry['studentFirstName']} ${entry['studentLastName']}';
                    final studentPhone = entry['studentEmergencyContact'];
                    final parentName = '${entry['parentFirstName']} ${entry['parentLastName']}';
                    final parentPhone = entry['parentMobileNumber'];
                    final relation = entry['relationship'];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.primaryGold,
                              child: Icon(Icons.family_restroom, color: AppColors.primaryNavy),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryNavy)),
                                  if (studentPhone != null && studentPhone.toString().isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(Icons.phone_android, size: 14, color: AppColors.mutedText),
                                        const SizedBox(width: 4),
                                        Text('Student: $studentPhone', style: const TextStyle(color: AppColors.mutedText)),
                                      ],
                                    ),
                                  const SizedBox(height: 8),
                                  Text('Parent ($relation): $parentName', style: const TextStyle(color: AppColors.deepNavy)),
                                  if (parentPhone != null && parentPhone.toString().isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(Icons.phone_android, size: 14, color: AppColors.mutedText),
                                        const SizedBox(width: 4),
                                        Text('Parent: $parentPhone', style: const TextStyle(color: AppColors.mutedText)),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                if (studentPhone != null && studentPhone.toString().isNotEmpty)
                                  IconButton(
                                    tooltip: 'Call Student',
                                    icon: const Icon(Icons.phone, color: AppColors.primaryNavy, size: 24),
                                    onPressed: () => _makePhoneCall(studentPhone.toString()),
                                  ),
                                if (parentPhone != null && parentPhone.toString().isNotEmpty)
                                  IconButton(
                                    tooltip: 'Call Parent',
                                    icon: const Icon(Icons.phone, color: AppColors.success, size: 24),
                                    onPressed: () => _makePhoneCall(parentPhone.toString()),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
