import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../../../../core/utils/app_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import '../../domain/models/student.dart';
import '../providers/student_providers.dart';
import '../../../fees/presentation/providers/fee_plans_providers.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  final Student? student;

  const StudentFormScreen({super.key, this.student});

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Student Info
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _genderController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  late String _status;
  String? _feePlanId;

  // Student Auth
  late TextEditingController _studentLoginController;
  late TextEditingController _studentPasswordController;

  // Parent Info
  late TextEditingController _parentFirstNameController;
  late TextEditingController _parentLastNameController;
  late TextEditingController _parentMobileController;

  // Parent Auth
  late TextEditingController _parentLoginController;
  late TextEditingController _parentPasswordController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.student?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.student?.lastName ?? '');
    _genderController = TextEditingController(text: widget.student?.gender ?? '');
    _addressController = TextEditingController(text: widget.student?.address ?? '');
    _emergencyContactController = TextEditingController(
      text: widget.student?.emergencyContactNumber ?? '',
    );
    _status = widget.student?.status ?? 'Active';
    _feePlanId = widget.student?.feePlanId;

    _studentLoginController = TextEditingController();
    _studentPasswordController = TextEditingController();
    _parentFirstNameController = TextEditingController();
    _parentLastNameController = TextEditingController();
    _parentMobileController = TextEditingController();
    _parentLoginController = TextEditingController();
    _parentPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();

    _studentLoginController.dispose();
    _studentPasswordController.dispose();
    _parentFirstNameController.dispose();
    _parentLastNameController.dispose();
    _parentMobileController.dispose();
    _parentLoginController.dispose();
    _parentPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.student == null) {
        final payload = {
          "studentFirstName": _firstNameController.text.trim(),
          "studentLastName": _lastNameController.text.trim(),
          "dateOfBirth": DateTime(2010, 1, 1).toIso8601String(),
          "gender": _genderController.text.trim(),
          "address": _addressController.text.trim(),
          "emergencyContactNumber": _emergencyContactController.text.trim(),
          "joiningDate": DateTime.now().toIso8601String(),
          "status": _status,
          "studentEmailOrUsername": _studentLoginController.text.trim(),
          "studentPassword": _studentPasswordController.text,
          "parentFirstName": _parentFirstNameController.text.trim(),
          "parentLastName": _parentLastNameController.text.trim(),
          "parentMobileNumber": _parentMobileController.text.trim(),
          "parentEmailOrUsername": _parentLoginController.text.trim(),
          "parentPassword": _parentPasswordController.text,
          "feePlanId": _feePlanId,
        };
        await ref.read(studentsProvider.notifier).addStudent(payload);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student & Parent created successfully!')),
          );
          context.pop();
        }
      } else {
        final updatedStudent = Student(
          id: widget.student?.id,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          dateOfBirth: widget.student?.dateOfBirth ?? DateTime(2010, 1, 1),
          gender: _genderController.text.trim(),
          address: _addressController.text.trim(),
          emergencyContactNumber: _emergencyContactController.text.trim(),
          joiningDate: widget.student?.joiningDate ?? DateTime.now(),
          status: _status,
          feePlanId: _feePlanId,
        );
        await ref.read(studentsProvider.notifier).updateStudent(updatedStudent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student updated!')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.textMutedSlate,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: icon != null ? Icon(icon, color: AppColors.goldFrameBorder, size: 20) : null,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.goldAccentLight, width: 1.3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkNavyText, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.crimsonAbsent, width: 1.3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.crimsonAbsent, width: 1.6),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.creamChipBackground,
                  border: Border.all(color: AppColors.goldFrameBorder, width: 1.8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.darkNavyText, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkNavyText,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1, color: AppColors.creamDivider),
          ),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;

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
              onTap: () => context.pop(),
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
        title: Text(
          isEditing ? 'Edit Student' : 'Enroll Student & Parent',
          style: const TextStyle(
            color: AppColors.goldBright,
            fontSize: 19,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionCard(
                      title: 'Student Information',
                      icon: Icons.person_outline,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                decoration: _inputDecoration('First Name'),
                                validator: (value) =>
                                    value == null || value.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                decoration: _inputDecoration('Last Name'),
                                validator: (value) =>
                                    value == null || value.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _genderController,
                                decoration: _inputDecoration('Gender', icon: Icons.wc),
                                validator: (value) =>
                                    value == null || value.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _status,
                                decoration: _inputDecoration('Status'),
                                items: const [
                                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _status = val);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emergencyContactController,
                          decoration: _inputDecoration(
                            'Emergency Contact',
                            icon: Icons.phone_outlined,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _addressController,
                          decoration: _inputDecoration(
                            'Address',
                            icon: Icons.location_on_outlined,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),

                    if (!isEditing) ...[
                      _buildSectionCard(
                        title: 'Student Login Credentials',
                        icon: Icons.lock_outline,
                        children: [
                          TextFormField(
                            controller: _studentLoginController,
                            decoration: _inputDecoration(
                              'Email or Username',
                              icon: Icons.alternate_email,
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _studentPasswordController,
                            decoration: _inputDecoration(
                              'Password',
                              icon: Icons.key_outlined,
                            ),
                            obscureText: true,
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Parent Information',
                        icon: Icons.family_restroom_outlined,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _parentFirstNameController,
                                  decoration: _inputDecoration('First Name'),
                                  validator: (value) =>
                                      value == null || value.isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _parentLastNameController,
                                  decoration: _inputDecoration('Last Name'),
                                  validator: (value) =>
                                      value == null || value.isEmpty ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _parentMobileController,
                            decoration: _inputDecoration(
                              'Mobile Number',
                              icon: Icons.phone_android_outlined,
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Parent Login Credentials',
                        icon: Icons.verified_user_outlined,
                        children: [
                          TextFormField(
                            controller: _parentLoginController,
                            decoration: _inputDecoration(
                              'Email or Username',
                              icon: Icons.alternate_email,
                            ),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _parentPasswordController,
                            decoration: _inputDecoration(
                              'Password',
                              icon: Icons.key_outlined,
                            ),
                            obscureText: true,
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ],

                    _buildSectionCard(
                      title: 'Fee Plan Assignment',
                      icon: Icons.account_balance_wallet_outlined,
                      children: [
                        ref.watch(feePlansProvider).when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, s) => Text(AppErrorHandler.toShortMessage(e)),
                              data: (plans) {
                                return DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  initialValue: _feePlanId,
                                  decoration: _inputDecoration(
                                    'Select Fee Plan',
                                    icon: Icons.workspace_premium_outlined,
                                  ),
                                  items: plans
                                      .map(
                                        (p) => DropdownMenuItem(
                                          value: p['id'].toString(),
                                          child: Text(
                                            p['name'].toString(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() => _feePlanId = val);
                                  },
                                );
                              },
                            ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyHeader,
                          foregroundColor: AppColors.goldBright,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: AppColors.goldBorder, width: 1.5),
                          ),
                        ),
                        onPressed: _saveStudent,
                        child: Text(
                          isEditing ? 'Save Changes' : 'Enroll Student',
                          style: const TextStyle(
                            color: AppColors.goldBright,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
