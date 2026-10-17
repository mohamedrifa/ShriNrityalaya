import '../../../../shared/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/network/api_client.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import 'package:shri_nrityalaya_app/features/auth/presentation/providers/auth_providers.dart';
import '../providers/fee_obligations_providers.dart';
import '../providers/fee_plans_providers.dart';

class FeeManagementScreen extends ConsumerStatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  ConsumerState<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends ConsumerState<FeeManagementScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userRole = ref.watch(authProvider).userRole;
    final isTeacherOrAdmin = userRole == 'Teacher' || userRole == 'SystemAdmin';

    final List<String> tabs = [
      'Monthly Dues',
      if (isTeacherOrAdmin) 'Pending Reviews',
      if (isTeacherOrAdmin) 'Fee Plans',
    ];

    if (_selectedIndex >= tabs.length) {
      _selectedIndex = 0;
    }

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navyHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard/teacher');
            }
          },
        ),
        title: const Text(
          'Fee Management',
          style: TextStyle(
            color: AppColors.goldBright,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Column(
        children: [
          // Top Pill Tab Bar Strip
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.creamWarmLightFbf6ea,
              border: Border(
                bottom: BorderSide(color: AppColors.creamWarmLightE5dac1, width: 1.0),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final bool isSelected = _selectedIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(right: index < tabs.length - 1 ? 10 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.navyDarkPill : AppColors.creamWarmLightF5efe0,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected ? AppColors.goldBorder : AppColors.accentToneD5c18f,
                            width: isSelected ? 1.6 : 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.14),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.navySlate1e2736,
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Tab Body Content
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                const _MonthlyDuesTab(),
                if (isTeacherOrAdmin) const _PendingReviewsList(),
                if (isTeacherOrAdmin) const _FeePlansTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TAB 1: MONTHLY DUES ─────────────────────────────────────────────────────
class _MonthlyDuesTab extends ConsumerWidget {
  const _MonthlyDuesTab();

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'ST';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final single = parts[0];
    return single.length >= 2 ? single.substring(0, 2).toUpperCase() : single.toUpperCase();
  }

  String _formatMonthYear(int month, int year) {
    final m = (month >= 1 && month <= 12) ? _monthNames[month - 1] : 'Oct';
    return '$m $year';
  }

  String _formatAmount(double amount) {
    final intVal = amount.round();
    final str = intVal.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obligationsState = ref.watch(feeObligationsProvider);
    final userRole = ref.watch(authProvider).userRole;
    final isTeacherOrAdmin = userRole == 'Teacher' || userRole == 'SystemAdmin';

    return Column(
      children: [
        // Navy Hero Banner with Inset Gold Frame
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyRoyal22365e, AppColors.navyHeader],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.goldFrameBorder.withValues(alpha: 0.75),
                width: 1.1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Month',
                        style: TextStyle(
                          color: AppColors.goldHeaderAccent,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Obligations',
                        style: TextStyle(
                          color: AppColors.goldHeaderAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isTeacherOrAdmin)
                  Material(
                    color: AppColors.crimsonAlertDab650,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () async {
                        try {
                          await ref
                              .read(feeObligationsProvider.notifier)
                              .generateObligations(DateTime.now().year, DateTime.now().month);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Obligations generated successfully!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
                            );
                          }
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: AppColors.navyDarkPill, size: 17),
                            SizedBox(width: 6),
                            Text(
                              'Generate Now',
                              style: TextStyle(
                                color: AppColors.navyDarkPill,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Obligations List
        Expanded(
          child: obligationsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => ErrorView(error: err, onRetry: () => ref.refresh(feeObligationsProvider)),
            data: (obligations) {
              if (obligations.isEmpty) {
                return const Center(
                  child: Text(
                    'No obligations found for this month.',
                    style: TextStyle(color: AppColors.primaryNavy, fontSize: 15),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: obligations.length,
                itemBuilder: (context, index) {
                  final ob = obligations[index];
                  final displayName = (ob.studentName != null && ob.studentName!.trim().isNotEmpty)
                      ? ob.studentName!
                      : 'Student ${ob.studentId.substring(0, 6)}';
                  final initials = _getInitials(ob.studentName);
                  final monthYear = _formatMonthYear(ob.month, ob.year);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.creamCardBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.goldAccentLight, width: 1.3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Gold-ringed Initials Avatar
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.creamSheetBackground,
                            border: Border.all(color: AppColors.goldTabIndicator, width: 3.2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.navySlate1c2536,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.5,
                            ),
                          ),
                        ),

                        // Vertical Divider
                        Container(
                          width: 1.2,
                          height: 76,
                          margin: const EdgeInsets.symmetric(horizontal: 13),
                          color: AppColors.textDarkSlate.withValues(alpha: 0.55),
                        ),

                        // Center: Student Name, Month/Year, Due & Paid Amounts
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.darkNavySurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                monthYear,
                                style: const TextStyle(
                                  color: AppColors.textMutedSlate,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Due Column
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '₹${_formatAmount(ob.amountDue)}',
                                        style: const TextStyle(
                                          color: AppColors.goldOchreDeep,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16.5,
                                        ),
                                      ),
                                      const Text(
                                        'Due',
                                        style: TextStyle(
                                          color: AppColors.textMutedSlate,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  // Paid Column
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '₹${_formatAmount(ob.amountPaid)}',
                                        style: const TextStyle(
                                          color: AppColors.darkNavySurface,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16.5,
                                        ),
                                      ),
                                      const Text(
                                        'Paid',
                                        style: TextStyle(
                                          color: AppColors.textMutedSlate,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Right: Status Badges & Action Pills
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: _buildRightPills(context, ref, ob, isTeacherOrAdmin),
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
    );
  }

  List<Widget> _buildRightPills(
    BuildContext context,
    WidgetRef ref,
    dynamic ob,
    bool isTeacherOrAdmin,
  ) {
    final String status = ob.status ?? 'Unpaid';

    if (status == 'Paid') {
      return [
        _buildPillBadge(
          label: 'PAID',
          bgColor: AppColors.greenSoftBg,
          textColor: AppColors.greenBadgeDark,
        ),
      ];
    }

    if (status == 'Unpaid') {
      return [
        if ((ob.amountPaid ?? 0) > 0) ...[
          _buildPillBadge(
            label: 'PAID',
            bgColor: AppColors.greenSoftBg,
            textColor: AppColors.greenBadgeDark,
          ),
          const SizedBox(height: 5),
        ],
        _buildPillBadge(
          label: 'UNPAID',
          bgColor: AppColors.crimsonBlushF9d8d6,
          textColor: AppColors.crimsonAbsent,
        ),
        const SizedBox(height: 6),
        if (isTeacherOrAdmin)
          _buildActionPillButton(
            label: 'Cash Paid',
            bgColor: AppColors.goldActionPill,
            textColor: AppColors.darkNavySurface,
            onTap: () async {
              try {
                await ref.read(dioProvider).post(
                  '/payments/manual-cash',
                  data: {'monthlyFeeObligationId': ob.id},
                );
                ref.read(feeObligationsProvider.notifier).loadObligations();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marked as Cash Paid!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
                  );
                }
              }
            },
          )
        else
          _buildActionPillButton(
            label: 'Pay Now',
            bgColor: AppColors.navyDarkPill,
            textColor: Colors.white,
            onTap: () => context.push('/payments/submit', extra: ob),
          ),
      ];
    }

    // Under Review or other status
    return [
      _buildPillBadge(
        label: status.toUpperCase(),
        bgColor: AppColors.creamWarmLightFdebd0,
        textColor: AppColors.crimsonDeep9a6700,
      ),
      if (!isTeacherOrAdmin && status == 'Under Review') ...[
        const SizedBox(height: 6),
        _buildActionPillButton(
          label: 'View Submission',
          bgColor: AppColors.goldActionPill,
          textColor: AppColors.darkNavySurface,
          onTap: () => context.push('/payments/details', extra: ob),
        ),
      ],
    ];
  }

  Widget _buildPillBadge({
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 84),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildActionPillButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 84),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── TAB 2: PENDING REVIEWS ──────────────────────────────────────────────────
class _PendingReviewsList extends ConsumerStatefulWidget {
  const _PendingReviewsList();

  @override
  ConsumerState<_PendingReviewsList> createState() => _PendingReviewsListState();
}

class _PendingReviewsListState extends ConsumerState<_PendingReviewsList> {
  List<dynamic> _payments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/payments');
      if (response.statusCode == 200) {
        final List all = response.data['data'];
        if (mounted) {
          setState(() {
            _payments = all.where((p) => p['status'] == 'PendingReview').toList();
            _errorMessage = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppErrorHandler.toShortMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reviewPayment(String id, String status) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/payments/$id/review', data: {'status': status, 'remarks': ''});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment $status!')),
        );
      }
      _fetchPayments();
      ref.read(feeObligationsProvider.notifier).loadObligations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null && _payments.isEmpty) {
      return ErrorView(
        message: _errorMessage,
        onRetry: () {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
          _fetchPayments();
        },
      );
    }
    if (_payments.isEmpty) {
      return const Center(
        child: Text(
          'No pending payment reviews.',
          style: TextStyle(color: AppColors.primaryNavy, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final p = _payments[index];
        final imageUrl = p['proofImageUrl'];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.creamCardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.goldAccentLight, width: 1.3),
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
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.creamSheetBackground,
                      border: Border.all(color: AppColors.goldTabIndicator, width: 2.8),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.receipt_long, color: AppColors.darkNavySurface, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount: ₹${p['amount']}',
                          style: const TextStyle(
                            color: AppColors.darkNavySurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ref: ${p['transactionReference'] ?? 'N/A'}',
                          style: const TextStyle(
                            color: AppColors.textMutedSlate,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.creamWarmLightF5efe0,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldTabIndicator),
                    ),
                    child: Text(
                      '${p['paymentMethod'] ?? 'Online'}',
                      style: const TextStyle(
                        color: AppColors.darkNavySurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (imageUrl != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Payment Proof:',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNavySurface,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    color: AppColors.creamWarmLightF0ead8,
                    child: Image.network(
                      '${ref.read(dioProvider).options.baseUrl.replaceAll('/api/v1', '')}$imageUrl',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Center(
                        child: Icon(Icons.broken_image, color: AppColors.mutedText, size: 36),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.crimsonAbsent,
                      side: const BorderSide(color: AppColors.crimsonAbsent, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    onPressed: () => _reviewPayment(p['id'], 'Rejected'),
                    child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenBadgeDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () => _reviewPayment(p['id'], 'Approved'),
                    child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── TAB 3: FEE PLANS ────────────────────────────────────────────────────────
class _FeePlansTab extends ConsumerWidget {
  const _FeePlansTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(feePlansProvider);

    return Column(
      children: [
        // Navy Header Banner with Inset Gold Frame
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyRoyal22365e, AppColors.navyHeader],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: AppColors.goldFrameBorder.withValues(alpha: 0.75),
                width: 1.1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academy Curriculum',
                        style: TextStyle(
                          color: AppColors.goldHeaderAccent,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Active Fee Plans',
                        style: TextStyle(
                          color: AppColors.goldHeaderAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: AppColors.crimsonAlertDab650,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => context.push('/fee-plans/form'),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: AppColors.navyDarkPill, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Add Plan',
                            style: TextStyle(
                              color: AppColors.navyDarkPill,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: plansAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => ErrorView(error: err, onRetry: () => ref.refresh(feeObligationsProvider)),
            data: (plans) {
              if (plans.isEmpty) {
                return const Center(
                  child: Text(
                    'No fee plans found.',
                    style: TextStyle(color: AppColors.primaryNavy, fontSize: 15),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.creamCardBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.goldAccentLight, width: 1.3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.creamSheetBackground,
                            border: Border.all(color: AppColors.goldTabIndicator, width: 3.0),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.navySlate1c2536,
                            size: 24,
                          ),
                        ),
                        Container(
                          width: 1.2,
                          height: 64,
                          margin: const EdgeInsets.symmetric(horizontal: 13),
                          color: AppColors.textDarkSlate.withValues(alpha: 0.55),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan['name'] ?? '',
                                style: const TextStyle(
                                  color: AppColors.darkNavySurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${plan['monthlyAmount']} / month',
                                style: const TextStyle(
                                  color: AppColors.goldOchreDeep,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              if (plan['description'] != null &&
                                  plan['description'].toString().trim().isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  plan['description'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textMutedSlate,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: AppColors.goldActionPill,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => context.push('/fee-plans/form', extra: plan),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  color: AppColors.darkNavySurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}
