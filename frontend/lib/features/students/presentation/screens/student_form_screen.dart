import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../../domain/models/student.dart';
import '../providers/student_providers.dart';

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
  late TextEditingController _bloodGroupController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  late String _status;

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
    _bloodGroupController = TextEditingController(text: widget.student?.bloodGroup ?? '');
    _addressController = TextEditingController(text: widget.student?.address ?? '');
    _emergencyContactController = TextEditingController(text: widget.student?.emergencyContactNumber ?? '');
    _status = widget.student?.status ?? 'Active';

    // Auth & Parent fields are only used during creation for now
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
    _bloodGroupController.dispose();
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
        // Create new student WITH parent and logins
        final payload = {
          "studentFirstName": _firstNameController.text.trim(),
          "studentLastName": _lastNameController.text.trim(),
          "dateOfBirth": DateTime(2010, 1, 1).toIso8601String(), // Default for demo
          "gender": _genderController.text.trim(),
          "bloodGroup": _bloodGroupController.text.trim(),
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
        };
        await ref.read(studentsProvider.notifier).addStudent(payload);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student & Parent created successfully!')));
          context.pop();
        }
      } else {
        // Update existing student (No auth logic for updates yet)
        final updatedStudent = Student(
          id: widget.student?.id,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          dateOfBirth: widget.student?.dateOfBirth ?? DateTime(2010, 1, 1),
          gender: _genderController.text.trim(),
          bloodGroup: _bloodGroupController.text.trim(),
          address: _addressController.text.trim(),
          emergencyContactNumber: _emergencyContactController.text.trim(),
          joiningDate: widget.student?.joiningDate ?? DateTime.now(),
          status: _status,
        );
        await ref.read(studentsProvider.notifier).updateStudent(updatedStudent);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student updated!')));
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving student: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Student' : 'Enroll New Student & Parent'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
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
                    const Text('Student Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? 'Required' : null)),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? 'Required' : null)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _genderController, decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? 'Required' : null)),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _bloodGroupController, decoration: const InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()), maxLines: 2),
                    const SizedBox(height: 16),
                    TextFormField(controller: _emergencyContactController, decoration: const InputDecoration(labelText: 'Emergency Contact', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    
                    if (!isEditing) ...[
                      const Divider(height: 32, thickness: 2),
                      const Text('Student Login Credentials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                      const SizedBox(height: 12),
                      TextFormField(controller: _studentLoginController, decoration: const InputDecoration(labelText: 'Email or Username', border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? 'Required' : null),
                      const SizedBox(height: 16),
                      TextFormField(controller: _studentPasswordController, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), obscureText: true, validator: (value) => value == null || value.isEmpty ? 'Required' : null),
                      
                      const Divider(height: 32, thickness: 2),
                      const Text('Parent Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _parentFirstNameController, decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? 'Required' : null)),
                          const SizedBox(width: 16),
                          Expanded(child: TextFormField(controller: _parentLastNameController, decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? 'Required' : null)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(controller: _parentMobileController, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? 'Required' : null),
                      const SizedBox(height: 16),
                      
                      const Text('Parent Login Credentials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                      const SizedBox(height: 12),
                      TextFormField(controller: _parentLoginController, decoration: const InputDecoration(labelText: 'Email or Username', border: OutlineInputBorder()), validator: (value) => value == null || value.isEmpty ? 'Required' : null),
                      const SizedBox(height: 16),
                      TextFormField(controller: _parentPasswordController, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), obscureText: true, validator: (value) => value == null || value.isEmpty ? 'Required' : null),
                    ],

                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: ['Active', 'Inactive', 'Graduated'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) { if (val != null) setState(() => _status = val); },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: AppColors.primaryNavy),
                        onPressed: _saveStudent,
                        child: Text(isEditing ? 'Save Changes' : 'Enroll Student', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
