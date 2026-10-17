import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import 'package:shri_nrityalaya_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:shri_nrityalaya_app/features/events/presentation/providers/event_providers.dart';
import 'package:shri_nrityalaya_app/features/events/domain/models/academy_event.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/utils/app_error_handler.dart';
import '../../../../shared/widgets/error_view.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  static const Color _navyHeader = AppColors.navyHeader;
  static const Color _goldBright = AppColors.goldBright;
  static const Color _goldPrimary = AppColors.goldPrimaryEvent;
  static const Color _darkNavyText = AppColors.darkNavyText;

  String _feeFilter = 'All'; // 'All', 'Free', 'Paid'

  String _monthAbbr(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  void _cycleFilter() {
    setState(() {
      if (_feeFilter == 'All') {
        _feeFilter = 'Free';
      } else if (_feeFilter == 'Free') {
        _feeFilter = 'Paid';
      } else {
        _feeFilter = 'All';
      }
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1200),
        backgroundColor: _navyHeader,
        content: Text(
          'Filter: $_feeFilter Events',
          style: const TextStyle(color: _goldBright),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsProvider);
    final userRole = ref.watch(authProvider).userRole;
    final isTeacher = userRole == 'Teacher' || userRole == 'SystemAdmin';

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: _navyHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: const Text(
          'Academy Events',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _goldBright,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Filter Events ($_feeFilter)',
            onPressed: _cycleFilter,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.filter_alt_outlined,
                  color: Colors.white,
                  size: 23,
                ),
                Positioned(
                  right: -3,
                  bottom: -2,
                  child: Icon(
                    Icons.add,
                    size: 12,
                    color: _feeFilter == 'All' ? Colors.white : _goldBright,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: eventsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _navyHeader),
        ),
        error: (err, stack) => ErrorView(
          error: err,
          onRetry: () => ref.refresh(eventsProvider),
        ),
        data: (events) {
          final filteredEvents = events.where((e) {
            final isFree =
                e.participationFee == null || e.participationFee == 0;
            if (_feeFilter == 'Free') return isFree;
            if (_feeFilter == 'Paid') return !isFree;
            return true;
          }).toList();
      
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              // Top Ornate Hero Banner: "Upcoming Arangetrams & Events"
              _buildHeroBanner(),
              const SizedBox(height: 18),
      
              if (filteredEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 48,
                          color: _navyHeader.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No upcoming events.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textNeutralGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredEvents.map(
                  (e) => _buildEventCard(context, ref, e, isTeacher),
                ),
            ],
          );
        },
      ),
      floatingActionButton: isTeacher
          ? SizedBox(
              width: 54,
              height: 54,
              child: FloatingActionButton(
                backgroundColor: _goldPrimary,
                elevation: 4,
                shape: const CircleBorder(),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => const _EventBottomSheet(),
                  );
                },
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 118,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [
            AppColors.navyRoyal19305c,
            AppColors.navyHeader,
            AppColors.navyMidnight081226,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _goldPrimary, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: _navyHeader.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Inner gold hairline frame
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _goldBright.withValues(alpha: 0.38),
                    width: 0.9,
                  ),
                ),
              ),
            ),
          ),
          // Top-Left Ornate Mandala Corner Arch
          const Positioned(
            top: 0,
            left: 0,
            child: CustomPaint(
              size: Size(78, 72),
              painter: _MandalaCornerPainter(isRight: false),
            ),
          ),
          // Top-Right Ornate Mandala Corner Arch
          const Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: Size(78, 72),
              painter: _MandalaCornerPainter(isRight: true),
            ),
          ),
          // Center Text & Bottom Scrollwork Flourish
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Upcoming\nArangetrams & Events',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 19.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.creamWarmLightFdf8ec,
                    height: 1.22,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                CustomPaint(
                  size: const Size(110, 10),
                  painter: _ScrollworkFlourishPainter(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    WidgetRef ref,
    AcademyEvent e,
    bool isTeacher,
  ) {
    final isFree = e.participationFee == null || e.participationFee == 0;
    final dayStr = e.eventDate.day.toString().padLeft(2, '0');
    final monthStr = _monthAbbr(e.eventDate.month);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(2.2),
      decoration: BoxDecoration(
        color: _navyHeader,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _navyHeader.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.creamWarmLightFaf5ea,
          borderRadius: BorderRadius.circular(15.5),
          border: Border.all(
            color: _goldPrimary.withValues(alpha: 0.75),
            width: 1.1,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Date Column: Day / 25 / JAN
              SizedBox(
                width: 82,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _darkNavyText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dayStr,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _navyHeader,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        monthStr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _goldPrimary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Vertical Divider
              Container(
                width: 1,
                margin: const EdgeInsets.symmetric(vertical: 12),
                color: AppColors.creamWarmLightE2d8c3,
              ),

              // Right Event Info Column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _darkNavyText,
                          height: 1.22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 15,
                            color: _goldPrimary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              e.location.isEmpty ? 'Academy Hall' : e.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDarkSlate,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (e.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          e.description.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMutedSlate,
                            height: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      if (isFree) ...[
                        const Text(
                          'Participation Fee',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: _darkNavyText,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Fee Badge: FREE green pill or ₹Amount gold-bordered pill
                          if (isFree)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.greenEmerald1e825c,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'FREE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.creamEventCard,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _goldPrimary,
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                '₹${e.participationFee!.toInt()}',
                                style: const TextStyle(
                                  color: _darkNavyText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                          // Right Action Button: Edit Event or Register Now
                          if (isTeacher)
                            InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) => _EventBottomSheet(event: e),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.creamEventCard,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _goldPrimary,
                                    width: 1.2,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Edit Event',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _darkNavyText,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.edit,
                                      size: 13.5,
                                      color: AppColors.crimsonAlertB88924,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () async {
                                try {
                                  await ref
                                      .read(eventRepositoryProvider)
                                      .registerForEvent(
                                        e.id!,
                                        '00000000-0000-0000-0000-000000000000',
                                      );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Registered successfully!',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppErrorHandler.toShortMessage(error)),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.creamEventCard,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _goldPrimary,
                                    width: 1.2,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Register Now',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _darkNavyText,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Icon(
                                      Icons.auto_fix_high_rounded,
                                      size: 13.5,
                                      color: AppColors.crimsonAlertB88924,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
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

/// Decorative gold mandala corner arches for the "Upcoming Arangetrams & Events" banner.
class _MandalaCornerPainter extends CustomPainter {
  final bool isRight;
  const _MandalaCornerPainter({required this.isRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.goldBorder.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final origin = isRight ? Offset(size.width, 0) : Offset.zero;

    for (final r in [22.0, 36.0, 50.0, 62.0]) {
      canvas.drawCircle(origin, r, paint);
    }

    // Radial spokes inside corner quadrant
    const spokeCount = 7;
    for (int i = 0; i <= spokeCount; i++) {
      final t = i / spokeCount;
      final angle = isRight
          ? (math.pi / 2) + t * (math.pi / 2)
          : t * (math.pi / 2);
      final p1 = Offset(
        origin.dx + 22 * math.cos(angle),
        origin.dy + 22 * math.sin(angle),
      );
      final p2 = Offset(
        origin.dx + 62 * math.cos(angle),
        origin.dy + 62 * math.sin(angle),
      );
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Symmetrical gold scrollwork flourish below the hero banner title.
class _ScrollworkFlourishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.goldBorder.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round;

    final cy = size.height / 2;
    final cx = size.width / 2;

    // Center diamond/circle knot
    canvas.drawCircle(Offset(cx, cy), 2.5, paint);

    // Left scroll line
    final leftPath = Path()
      ..moveTo(cx - 5, cy)
      ..quadraticBezierTo(cx - 22, cy - 5, cx - 44, cy)
      ..quadraticBezierTo(cx - 50, cy + 2, cx - 46, cy + 4);
    canvas.drawPath(leftPath, paint);

    // Right scroll line
    final rightPath = Path()
      ..moveTo(cx + 5, cy)
      ..quadraticBezierTo(cx + 22, cy - 5, cx + 44, cy)
      ..quadraticBezierTo(cx + 50, cy + 2, cx + 46, cy + 4);
    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EventBottomSheet extends ConsumerStatefulWidget {
  final AcademyEvent? event;
  const _EventBottomSheet({this.event});

  @override
  ConsumerState<_EventBottomSheet> createState() => _EventBottomSheetState();
}

class _EventBottomSheetState extends ConsumerState<_EventBottomSheet> {
  static const Color _sheetCream = AppColors.creamSheetBackground;
  static const Color _fieldBg = AppColors.creamFieldBgLight;
  static const Color _navyHeader = AppColors.navyHeader;
  static const Color _darkNavyText = AppColors.darkNavyText;
  static const Color _goldPrimary = AppColors.goldPrimaryAmber;
  static const Color _goldBright = AppColors.goldBright;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locCtrl;
  late TextEditingController _feeCtrl;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _hasFee = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.event?.title ?? '');
    _descCtrl = TextEditingController(text: widget.event?.description ?? '');
    _locCtrl = TextEditingController(text: widget.event?.location ?? '');
    final existingFee = widget.event?.participationFee;
    _hasFee = existingFee != null && existingFee > 0;
    _feeCtrl = TextEditingController(
      text: _hasFee ? existingFee!.toInt().toString() : '500',
    );
    if (widget.event != null) {
      _selectedDate = widget.event!.eventDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  String _formatDisplayDate(DateTime dt) {
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
    final m = months[(dt.month - 1).clamp(0, 11)];
    final d = dt.day.toString().padLeft(2, '0');
    return '$m $d, ${dt.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  InputDecoration _inputDecoration({Widget? prefixIcon}) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.textNeutralGray, width: 1.1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.textNeutralGray, width: 1.1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _navyHeader, width: 1.6),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final isEdit = widget.event != null;
      final parsedFee =
          _hasFee ? (double.tryParse(_feeCtrl.text.trim()) ?? 0.0) : 0.0;

      if (isEdit) {
        final updated = AcademyEvent(
          id: widget.event!.id,
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          eventDate: _selectedDate,
          location: _locCtrl.text.trim(),
          participationFee: parsedFee,
          status: widget.event!.status,
        );
        await ref.read(eventsProvider.notifier).updateEvent(updated);
      } else {
        final newEvent = AcademyEvent(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          eventDate: _selectedDate,
          location: _locCtrl.text.trim(),
          participationFee: parsedFee,
          status: 'Upcoming',
        );
        await ref.read(eventsProvider.notifier).createEvent(newEvent);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.event != null;

    return Container(
      decoration: const BoxDecoration(
        color: _sheetCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 22,
        left: 22,
        right: 22,
        top: 12,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Gold Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: _goldPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header: "Create New Event" with gold "Event"
              Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(
                        text: isEdit ? 'Edit ' : 'Create New ',
                        style: const TextStyle(color: _darkNavyText),
                      ),
                      const TextSpan(
                        text: 'Event',
                        style: TextStyle(color: _goldPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Event Title
              const Text(
                'Event Title',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _darkNavyText,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleCtrl,
                decoration: _inputDecoration(),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // Date & Time
              const Text(
                'Date & Time',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _darkNavyText,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDate,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: _fieldBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.textNeutralGray,
                          width: 1.1,
                        ),
                      ),
                      child: Text(
                        _formatDisplayDate(_selectedDate),
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: _darkNavyText,
                        ),
                      ),
                    ),
                    // Gold Seal Calendar Badge on Right
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _goldPrimary,
                          border: Border.all(
                            color: AppColors.goldBright,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _goldPrimary.withValues(alpha: 0.35),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Location
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _darkNavyText,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _locCtrl,
                decoration: _inputDecoration(
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: _goldPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Event Description
              const Text(
                'Event Description',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _darkNavyText,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 16),

              // Participation Fee Row with Toggle + ₹ Input Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Participation Fee',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _darkNavyText,
                    ),
                  ),
                  Container(
                    height: 38,
                    padding: const EdgeInsets.only(left: 4, right: 12),
                    decoration: BoxDecoration(
                      color: _fieldBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _goldPrimary.withValues(alpha: 0.75),
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: 0.78,
                          child: Switch(
                            value: _hasFee,
                            activeThumbColor: _goldPrimary,
                            activeTrackColor:
                                _goldPrimary.withValues(alpha: 0.35),
                            onChanged: (val) => setState(() => _hasFee = val),
                          ),
                        ),
                        if (_hasFee)
                          SizedBox(
                            width: 58,
                            child: TextField(
                              controller: _feeCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: _darkNavyText,
                              ),
                              decoration: const InputDecoration(
                                prefixText: '₹',
                                prefixStyle: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: _darkNavyText,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              'FREE',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.greenEmerald1e825c,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Bottom Cancel & Create Event Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.creamWarmLightF5ecd8,
                          side: const BorderSide(
                            color: AppColors.crimsonAlertC97a63,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.crimsonDeepA64b38,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navyHeader,
                          foregroundColor: _goldBright,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _goldBright,
                                ),
                              )
                            : Text(
                                isEdit ? 'Save Event' : 'Create Event',
                                style: const TextStyle(
                                  color: _goldBright,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
