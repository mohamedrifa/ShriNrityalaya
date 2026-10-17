import '../../../../shared/widgets/error_view.dart';
import '../../../../core/utils/app_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import '../../../directory/presentation/providers/directory_providers.dart';
import '../providers/student_providers.dart';

class StudentsListScreen extends ConsumerStatefulWidget {
  const StudentsListScreen({super.key});

  @override
  ConsumerState<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends ConsumerState<StudentsListScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All';

  String _getInitials(String firstName, String lastName) {
    final f = firstName.trim().isNotEmpty ? firstName.trim()[0] : '';
    final l = lastName.trim().isNotEmpty ? lastName.trim()[0] : '';
    final res = '$f$l'.toUpperCase();
    return res.isNotEmpty ? res : 'ST';
  }

  @override
  Widget build(BuildContext context) {
    final studentsState = ref.watch(studentsProvider);
    final directoryState = ref.watch(directoryProvider);

    // Map student full name -> directory parent entry if available
    final Map<String, Map<String, dynamic>> parentMap = {};
    directoryState.whenData((entries) {
      for (final entry in entries) {
        final key = '${entry['studentFirstName'] ?? ''} ${entry['studentLastName'] ?? ''}'
            .trim()
            .toLowerCase();
        if (key.isNotEmpty) {
          parentMap[key] = entry;
        }
      }
    });

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
          'Manage Students',
          style: TextStyle(
            color: AppColors.goldBright,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => context.push('/students/form'),
              child: const Icon(
                Icons.contact_page_rounded,
                color: AppColors.goldBright,
                size: 26,
              ),
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
                    tooltip: 'Filter by Status',
                    initialValue: _statusFilter,
                    onSelected: (value) {
                      setState(() => _statusFilter = value);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'All', child: Text('All Students')),
                      PopupMenuItem(value: 'Active', child: Text('Active Only')),
                      PopupMenuItem(value: 'Inactive', child: Text('Inactive Only')),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_statusFilter != 'All')
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              _statusFilter,
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

          // Students List
          Expanded(
            child: studentsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => ErrorView(error: error, onRetry: () => ref.refresh(studentsProvider)),
              data: (students) {
                final filtered = students.where((student) {
                  final fullName = '${student.firstName} ${student.lastName}'.toLowerCase();
                  final parentEntry = parentMap[fullName];
                  final parentName = parentEntry != null
                      ? '${parentEntry['parentFirstName'] ?? ''} ${parentEntry['parentLastName'] ?? ''}'
                          .toLowerCase()
                      : '';
                  final phone = (student.emergencyContactNumber ?? '').toLowerCase();

                  final matchesQuery = _searchQuery.isEmpty ||
                      fullName.contains(_searchQuery) ||
                      parentName.contains(_searchQuery) ||
                      phone.contains(_searchQuery);

                  final matchesStatus = _statusFilter == 'All' ||
                      student.status.toLowerCase() == _statusFilter.toLowerCase();

                  return matchesQuery && matchesStatus;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No students found.',
                      style: TextStyle(color: AppColors.primaryNavy, fontSize: 15),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 90),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    final fullName = '${student.firstName} ${student.lastName}';
                    final initials = _getInitials(student.firstName, student.lastName);
                    final joinedDate = student.joiningDate.toLocal().toString().split(' ')[0];
                    final phone = (student.emergencyContactNumber != null &&
                            student.emergencyContactNumber!.trim().isNotEmpty)
                        ? student.emergencyContactNumber!
                        : 'Not provided';

                    final parentEntry = parentMap[fullName.trim().toLowerCase()];
                    final String? parentName = parentEntry != null
                        ? '${parentEntry['parentFirstName'] ?? ''} ${parentEntry['parentLastName'] ?? ''}'
                            .trim()
                        : null;
                    final String? parentPhone = parentEntry?['parentMobileNumber']?.toString();
                    final String relation = (parentEntry?['relationship']?.toString().isNotEmpty == true)
                        ? parentEntry!['relationship'].toString()
                        : student.status;

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
                          // Top Row: Avatar + Student Info + Edit Circle Button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Gold-ringed Initials Circle
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

                              // Student Name, Gender/Status, Phone
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fullName,
                                      style: const TextStyle(
                                        color: AppColors.darkNavyText,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${student.gender.isNotEmpty ? student.gender : 'Student'} • Joined $joinedDate',
                                      style: const TextStyle(
                                        color: AppColors.textDarkSlate,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12.5,
                                      ),
                                    ),
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
                                            phone,
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
                                ),
                              ),

                              // Right: Navy & Gold Circular Edit Button
                              GestureDetector(
                                onTap: () => context.push('/students/form', extra: student),
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
                                    Icons.edit_outlined,
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

                          // Bottom Row: Status/Parent Pill + Details + Delete Circle Button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _buildBadgePill(student.status, index),
                                        if (parentEntry != null &&
                                            relation.toLowerCase() != student.status.toLowerCase()) ...[
                                          const SizedBox(width: 6),
                                          _buildBadgePill(relation, index + 1),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            (parentName != null && parentName.isNotEmpty)
                                                ? parentName
                                                : (student.address != null &&
                                                        student.address!.trim().isNotEmpty
                                                    ? student.address!
                                                    : 'Enrolled Student'),
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.darkNavyText,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.5,
                                            ),
                                          ),
                                        ),
                                        if (parentPhone != null && parentPhone.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 10),
                                            child: Text(
                                              parentPhone,
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
                                ),
                              ),

                              // Right: Green/Gold Circular Delete Action Button
                              GestureDetector(
                                onTap: () => _confirmDelete(context, ref, student.id!),
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
                                    Icons.delete_outline,
                                    color: AppColors.goldBright,
                                    size: 19,
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.navyHeader,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: AppColors.goldBorder, width: 1.5),
        ),
        onPressed: () => context.push('/students/form'),
        icon: const Icon(Icons.person_add_alt_1, color: AppColors.goldBright, size: 20),
        label: const Text(
          'Enroll Student',
          style: TextStyle(
            color: AppColors.goldBright,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBadgePill(String label, int variantIndex) {
    final lower = label.toLowerCase();
    if (lower == 'active' || lower == 'father') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
        decoration: BoxDecoration(
          color: AppColors.greenPillBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.greenPresent,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
      );
    }
    if (lower == 'mother' || lower == 'inactive') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
        decoration: BoxDecoration(
          color: AppColors.sandWarmMutedF7dea8,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
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
        label,
        style: const TextStyle(
          color: AppColors.goldBright,
          fontWeight: FontWeight.w600,
          fontSize: 11.5,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String studentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.creamCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.goldAccentLight, width: 1.3),
        ),
        title: const Text(
          'Delete Student',
          style: TextStyle(color: AppColors.darkNavyText, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to delete this student?',
          style: TextStyle(color: AppColors.textDarkSlate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textDarkSlate)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.crimsonAbsent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(studentsProvider.notifier).deleteStudent(studentId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
          );
        }
      }
    }
  }
}
