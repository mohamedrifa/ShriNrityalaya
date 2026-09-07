import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../../domain/models/student.dart';
import '../providers/student_providers.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  final Student? student;

  const StudentFormScreen({Key? key, this.student}) : super(key: key);

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _genderController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  late String _status;

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
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _bloodGroupController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final newStudent = Student(
      id: widget.student?.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      dateOfBirth: widget.student?.dateOfBirth ?? DateTime(2010, 1, 1), // Default for now
      gender: _genderController.text.trim(),
      bloodGroup: _bloodGroupController.text.trim(),
      address: _addressController.text.trim(),
      emergencyContactNumber: _emergencyContactController.text.trim(),
      joiningDate: widget.student?.joiningDate ?? DateTime.now(),
      status: _status,
    );

    try {
      if (widget.student == null) {
        await ref.read(studentsProvider.notifier).addStudent(newStudent);
      } else {
        await ref.read(studentsProvider.notifier).updateStudent(newStudent);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.student == null ? 'Student added!' : 'Student updated!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving student: $e')),
        );
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
        title: Text(isEditing ? 'Edit Student' : 'Add Student'),
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
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _genderController,
                      decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bloodGroupController,
                      decoration: const InputDecoration(labelText: 'Blood Group', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emergencyContactController,
                      decoration: const InputDecoration(labelText: 'Emergency Contact', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: ['Active', 'Inactive', 'Graduated'].map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.primaryNavy,
                        ),
                        onPressed: _saveStudent,
                        child: Text(
                          isEditing ? 'Save Changes' : 'Add Student',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
