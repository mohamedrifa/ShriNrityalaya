import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  List<dynamic> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final dio = ref.read(dioProvider);
      // Fetching all students from the DB (simulating a batch fetch)
      final response = await dio.get('/students');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          _students = data.map((s) => {
            'id': s['id'],
            'name': '${s['firstName']} ${s['lastName']}',
            'present': true // default to present
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load students.')));
      }
    }
  }

  Future<void> _submitAttendance() async {
    // Collect attendance records
    final records = _students.map((s) => {
      'studentId': s['id'],
      'classSessionId': '00000000-0000-0000-0000-000000000000', // placeholder for actual session
      'status': s['present'] == true ? 'Present' : 'Absent',
    }).toList();

    try {
      final dio = ref.read(dioProvider);
      await dio.post('/attendance/bulk', data: records);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance submitted successfully!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit attendance.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerLeft,
            color: Colors.white10,
            child: const Text(
              'Beginner Batch - Today',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _students.isEmpty 
          ? const Center(child: Text('No students found.'))
          : ListView.separated(
              itemCount: _students.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final student = _students[index];
                return CheckboxListTile(
                  title: Text(student['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(student['present'] == true ? 'Present' : 'Absent', 
                    style: TextStyle(color: student['present'] == true ? AppColors.success : AppColors.error)),
                  value: student['present'] as bool,
                  activeColor: AppColors.success,
                  onChanged: (value) {
                    setState(() {
                      student['present'] = value;
                    });
                  },
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitAttendance,
            child: const Text('Submit Attendance'),
          ),
        ),
      ),
    );
  }
}
