import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  static const Color _navyHeader = Color(0xFF0B1B3B);
  static const Color _navyCircleBtn = Color(0xFF1A2D52);
  static const Color _batchBannerBg = Color(0xFF2B3E5E);
  static const Color _creamSheet = Color(0xFFFAF3E3);
  static const Color _darkNavyText = Color(0xFF0E1D3A);
  static const Color _goldTitle = Color(0xFFE5C165);
  static const Color _goldBorder = Color(0xFFD5B258);
  static const Color _avatarFill = Color(0xFFEDE1C4);
  static const Color _avatarBorder = Color(0xFFB89648);
  static const Color _avatarText = Color(0xFF7A5C22);
  static const Color _presentGreen = Color(0xFF2FA35A);
  static const Color _absentRed = Color(0xFFA94444);

  List<dynamic> _students = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  String _initialsForName(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'ST';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _dateLabel() {
    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    if (isToday) return 'Today';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[(_selectedDate.month - 1).clamp(0, 11)];
    final d = _selectedDate.day.toString().padLeft(2, '0');
    return '$m $d, ${_selectedDate.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _fetchStudents() async {
    try {
      final dio = ref.read(dioProvider);
      // Fetching all students from the DB (simulating a batch fetch)
      final response = await dio.get('/students');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          _students = data
              .map(
                (s) => {
                  'id': s['id'],
                  'name': '${s['firstName'] ?? ''} ${s['lastName'] ?? ''}'
                      .trim(),
                  'present': true, // default to present
                },
              )
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load students.')),
        );
      }
    }
  }

  Future<void> _submitAttendance() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // Collect attendance records
    final records = _students
        .map(
          (s) => {
            'studentId': s['id'],
            'classSessionId':
                '00000000-0000-0000-0000-000000000000', // placeholder for actual session
            'status': s['present'] == true ? 'Present' : 'Absent',
          },
        )
        .toList();

    try {
      final dio = ref.read(dioProvider);
      await dio.post('/attendance/bulk', data: records);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance submitted successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit attendance.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _navyHeader,
      body: Column(
        children: [
          // 1. Deep Navy Top AppBar Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  // Circular Back Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _navyCircleBtn,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Mark Attendance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: _goldTitle,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  // Circular Calendar Button
                  GestureDetector(
                    onTap: _pickDate,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _navyCircleBtn,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Slate-Navy Sub-Banner ("Beginner Batch - Today 🗓️") + Rounded Cream Sheet
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _batchBannerBg,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.10),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Batch & Date Row
                  GestureDetector(
                    onTap: _pickDate,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Beginner Batch - ${_dateLabel()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAD49B),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: _goldBorder,
                                width: 0.8,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: _darkNavyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Rounded Warm Cream Student Roster Sheet
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: _creamSheet,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Student Roster List
                          Expanded(
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: _goldBorder,
                                    ),
                                  )
                                : _students.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No students found.',
                                      style: TextStyle(
                                        color: _darkNavyText,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      18,
                                      10,
                                      18,
                                      16,
                                    ),
                                    itemCount: _students.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Color(0xFFEAE0CA),
                                        ),
                                    itemBuilder: (context, index) {
                                      final student = _students[index];
                                      final String name =
                                          (student['name'] as String?) ??
                                          'Student';
                                      final bool isPresent =
                                          (student['present'] as bool?) ?? true;
                                      final String initials = _initialsForName(
                                        name,
                                      );

                                      return InkWell(
                                        onTap: () {
                                          setState(() {
                                            student['present'] = !isPresent;
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 4,
                                          ),
                                          child: Row(
                                            children: [
                                              // Initials Circle Avatar
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _avatarFill,
                                                  border: Border.all(
                                                    color: _avatarBorder,
                                                    width: 1.3,
                                                  ),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  initials,
                                                  style: const TextStyle(
                                                    color: _avatarText,
                                                    fontSize: 15.5,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.4,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 14),

                                              // Name + Present/Absent Subtitle
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: _darkNavyText,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      isPresent
                                                          ? 'Present'
                                                          : 'Absent',
                                                      style: TextStyle(
                                                        color: isPresent
                                                            ? _presentGreen
                                                            : _absentRed,
                                                        fontSize: 13.5,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 12),

                                              // Custom Rounded Checkbox
                                              AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 160,
                                                ),
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: isPresent
                                                      ? _presentGreen
                                                      : const Color(0xFFF6EFE0),
                                                  borderRadius:
                                                      BorderRadius.circular(7),
                                                  border: isPresent
                                                      ? null
                                                      : Border.all(
                                                          color: const Color(
                                                            0xFFD5C19D,
                                                          ),
                                                          width: 1.6,
                                                        ),
                                                ),
                                                alignment: Alignment.center,
                                                child: isPresent
                                                    ? const Icon(
                                                        Icons.check_rounded,
                                                        color: Colors.white,
                                                        size: 20,
                                                      )
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          // 4. Bottom Sticky "Submit Attendance" Bar
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _creamSheet,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, -3),
                                ),
                              ],
                            ),
                            child: SafeArea(
                              top: false,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  18,
                                  10,
                                  18,
                                  12,
                                ),
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: _darkNavyText,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _goldBorder,
                                      width: 1.4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _darkNavyText.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: (_isLoading || _isSubmitting)
                                          ? null
                                          : _submitAttendance,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Center(
                                        child: _isSubmitting
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2.2,
                                                      color: _goldTitle,
                                                    ),
                                              )
                                            : const Text(
                                                'Submit Attendance',
                                                style: TextStyle(
                                                  color: _goldTitle,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
