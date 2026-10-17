import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_view.dart';
import '../providers/directory_providers.dart';

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  String _searchQuery = '';
  String _relationFilter = 'All';

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleaned = phoneNumber.trim();
    if (cleaned.isEmpty) return;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleaned,
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

  String _getInitials(String firstName, String lastName) {
    final f = firstName.trim().isNotEmpty ? firstName.trim()[0] : '';
    final l = lastName.trim().isNotEmpty ? lastName.trim()[0] : '';
    final res = '$f$l'.toUpperCase();
    return res.isNotEmpty ? res : 'ST';
  }

  @override
  Widget build(BuildContext context) {
    final directoryState = ref.watch(directoryProvider);

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navyHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: GestureDetector(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/dashboard/teacher');
                }
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.navyCardFill,
                  border: Border.all(
                    color: AppColors.goldBorder.withValues(alpha: 0.45),
                    width: 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.goldBright,
                  size: 19,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          'Directory',
          style: TextStyle(
            color: AppColors.goldBright,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.contact_phone_rounded,
              color: AppColors.goldBright,
              size: 25,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Pill Search & Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.navyCardStroke, width: 1.3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldFrameBorder.withValues(alpha: 0.22),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.goldFrameBorder, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search student or parent...',
                        hintStyle: TextStyle(
                          color: AppColors.grayDark5a6372,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        color: AppColors.darkNavyText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Filter by Relationship',
                    initialValue: _relationFilter,
                    onSelected: (value) {
                      setState(() => _relationFilter = value);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'All', child: Text('All Contacts')),
                      PopupMenuItem(value: 'Father', child: Text('Father')),
                      PopupMenuItem(value: 'Mother', child: Text('Mother')),
                      PopupMenuItem(value: 'Guardian', child: Text('Guardian')),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_relationFilter != 'All')
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              _relationFilter,
                              style: const TextStyle(
                                color: AppColors.goldFrameBorder,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const Icon(
                          Icons.filter_alt_outlined,
                          color: AppColors.goldFrameBorder,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Directory Cards List
          Expanded(
            child: directoryState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => ErrorView(
                error: err,
                onRetry: () => ref.refresh(directoryProvider),
              ),
              data: (directory) {
                final filtered = directory.where((entry) {
                  final studentName =
                      '${entry['studentFirstName'] ?? ''} ${entry['studentLastName'] ?? ''}'
                          .toLowerCase();
                  final parentName =
                      '${entry['parentFirstName'] ?? ''} ${entry['parentLastName'] ?? ''}'
                          .toLowerCase();
                  final studentPhone = (entry['studentEmergencyContact'] ?? '')
                      .toString()
                      .toLowerCase();
                  final parentPhone = (entry['parentMobileNumber'] ?? '')
                      .toString()
                      .toLowerCase();
                  final relation = (entry['relationship'] ?? '').toString();

                  final matchesSearch = _searchQuery.isEmpty ||
                      studentName.contains(_searchQuery) ||
                      parentName.contains(_searchQuery) ||
                      studentPhone.contains(_searchQuery) ||
                      parentPhone.contains(_searchQuery);

                  final matchesRelation = _relationFilter == 'All' ||
                      relation.toLowerCase() == _relationFilter.toLowerCase();

                  return matchesSearch && matchesRelation;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching records found.',
                      style: TextStyle(color: AppColors.primaryNavy, fontSize: 15),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    final sFirst = (entry['studentFirstName'] ?? '').toString();
                    final sLast = (entry['studentLastName'] ?? '').toString();
                    final studentName = '$sFirst $sLast'.trim();
                    final initials = _getInitials(sFirst, sLast);

                    final studentPhone = (entry['studentEmergencyContact'] ?? '').toString();
                    final parentName =
                        '${entry['parentFirstName'] ?? ''} ${entry['parentLastName'] ?? ''}'
                            .trim();
                    final parentPhone = (entry['parentMobileNumber'] ?? '').toString();
                    final rawRelation = (entry['relationship'] ?? '').toString().trim();
                    final relationLabel = rawRelation.isNotEmpty ? rawRelation : 'Guardian';
                    final batchSubtitle = (entry['batchName'] ??
                            entry['className'] ??
                            'Bharatanatyam Batch')
                        .toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.navyCardBorder, width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Top Section: Student Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Gold-ringed Initials Avatar
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.creamChipBackground,
                                  border: Border.all(
                                    color: AppColors.goldFrameBorder,
                                    width: 2.2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: AppColors.darkNavyText,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Student Name, Class/Batch, Phone
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      studentName.isNotEmpty ? studentName : 'Student',
                                      style: const TextStyle(
                                        color: AppColors.darkNavyText,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      batchSubtitle,
                                      style: const TextStyle(
                                        color: AppColors.textDarkSlate,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (studentPhone.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            size: 13.5,
                                            color: AppColors.darkNavyText,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              studentPhone,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.darkNavyText,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Call Student Circular Navy & Gold Button
                              GestureDetector(
                                onTap: studentPhone.isNotEmpty
                                    ? () => _makePhoneCall(studentPhone)
                                    : null,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.navyHeader,
                                    border: Border.all(
                                      color: AppColors.goldBorder,
                                      width: 1.8,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.phone_in_talk_rounded,
                                    color: AppColors.goldBright,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.creamDivider,
                            ),
                          ),

                          // Bottom Section: Parent / Guardian Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildRelationshipPill(relationLabel, index),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            parentName.isNotEmpty ? parentName : 'Parent / Guardian',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.darkNavyText,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        if (parentPhone.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8, right: 10),
                                            child: Text(
                                              parentPhone,
                                              style: const TextStyle(
                                                color: AppColors.darkNavyText,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Call Parent Circular Forest-Green & Gold Button
                              GestureDetector(
                                onTap: parentPhone.isNotEmpty
                                    ? () => _makePhoneCall(parentPhone)
                                    : null,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.greenDeep1f4732,
                                    border: Border.all(
                                      color: AppColors.goldBorder,
                                      width: 1.8,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.phone_in_talk_rounded,
                                    color: AppColors.goldBright,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildRelationshipPill(String relation, int index) {
    final lower = relation.toLowerCase();

    // Match Father (mint green), Mother (warm amber), Guardian (navy with gold border)
    if (lower == 'father' || (lower == 'parent' && index % 3 == 0)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
        decoration: BoxDecoration(
          color: AppColors.greenPillBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          relation,
          style: const TextStyle(
            color: AppColors.greenPresent,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
      );
    }

    if (lower == 'mother' || (lower == 'parent' && index % 3 == 1)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
        decoration: BoxDecoration(
          color: AppColors.sandWarmMutedF7dea8,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          relation,
          style: const TextStyle(
            color: AppColors.bronzeOchreText,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
      decoration: BoxDecoration(
        color: AppColors.darkNavyText,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.goldBorder, width: 1.1),
      ),
      child: Text(
        relation,
        style: const TextStyle(
          color: AppColors.goldBright,
          fontWeight: FontWeight.w600,
          fontSize: 11.5,
        ),
      ),
    );
  }
}
