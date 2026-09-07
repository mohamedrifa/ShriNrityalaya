import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/network/api_client.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:shri_nrityalaya_app/features/auth/presentation/providers/auth_providers.dart';
import '../providers/fee_obligations_providers.dart';

class FeeManagementScreen extends ConsumerStatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  ConsumerState<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends ConsumerState<FeeManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.warmCream,
        appBar: AppBar(
          title: const Text('Fee Management'),
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: AppColors.primaryGold,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.primaryGold,
            tabs: [
              Tab(text: 'Monthly Dues'),
              Tab(text: 'Pending Reviews'),
              Tab(text: 'Fee Plans'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _MonthlyDuesTab(),
            _buildPendingReviewsTab(context),
            _buildFeePlansTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingReviewsTab(BuildContext context) {
    return const _PendingReviewsList();
  }

  Widget _buildFeePlansTab(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: AppColors.primaryNavy),
            title: Text(index == 0 ? 'Beginner Monthly Plan' : 'Intermediate Monthly Plan', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(index == 0 ? '₹2,000 / month' : '₹3,000 / month'),
            trailing: const Icon(Icons.edit, color: AppColors.mutedText),
            onTap: () {},
          ),
        );
      },
    );
  }
}

class _PendingReviewsList extends ConsumerStatefulWidget {
  const _PendingReviewsList();
  @override
  ConsumerState<_PendingReviewsList> createState() => _PendingReviewsListState();
}

class _PendingReviewsListState extends ConsumerState<_PendingReviewsList> {
  List<dynamic> _payments = [];
  bool _isLoading = true;

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
        setState(() {
          _payments = all.where((p) => p['status'] == 'PendingReview').toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reviewPayment(String id, String status) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/payments/$id/review', data: {'status': status, 'remarks': ''});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment $status!')));
      _fetchPayments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_payments.isEmpty) return const Center(child: Text('No pending reviews.'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final p = _payments[index];
        final imageUrl = p['proofImageUrl'];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Amount: \$${p['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(p['paymentMethod']),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Ref: ${p['transactionReference']}', style: const TextStyle(color: AppColors.mutedText)),
                if (imageUrl != null) ...[
                  const SizedBox(height: 12),
                  const Text('Payment Proof:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      '${ref.read(dioProvider).options.baseUrl.replaceAll('/api/v1', '')}$imageUrl', 
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _reviewPayment(p['id'], 'Rejected'),
                      child: const Text('Reject', style: TextStyle(color: AppColors.error)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      onPressed: () => _reviewPayment(p['id'], 'Approved'),
                      child: const Text('Approve', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildFeePlansTab(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: AppColors.primaryNavy),
            title: Text(index == 0 ? 'Beginner Monthly Plan' : 'Intermediate Monthly Plan', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(index == 0 ? '₹2,000 / month' : '₹3,000 / month'),
            trailing: const Icon(Icons.edit, color: AppColors.mutedText),
            onTap: () {},
          ),
        );
      },
    );
  }
}

class _MonthlyDuesTab extends ConsumerWidget {
  const _MonthlyDuesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obligationsState = ref.watch(feeObligationsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Month Obligations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await ref.read(feeObligationsProvider.notifier)
                        .generateObligations(DateTime.now().year, DateTime.now().month);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Obligations generated successfully!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to generate: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.auto_awesome, color: AppColors.primaryNavy),
                label: const Text('Generate Now', style: TextStyle(color: AppColors.primaryNavy)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
              ),
            ],
          ),
        ),
        Expanded(
          child: obligationsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (obligations) {
              if (obligations.isEmpty) {
                return const Center(child: Text('No obligations found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: obligations.length,
                itemBuilder: (context, index) {
                  final ob = obligations[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        'Student ID: ${ob.studentId.substring(0, 8)}...',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Due: \$${ob.amountDue} | Paid: \$${ob.amountPaid}\nMonth: ${ob.month}/${ob.year}'),
                      trailing: ob.status == 'Unpaid' 
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (ref.read(authProvider).userRole != 'Teacher')
                                  ElevatedButton(
                                    onPressed: () => context.push('/payments/submit', extra: ob),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy),
                                    child: const Text('Pay Now', style: TextStyle(color: Colors.white)),
                                  ),
                                if (ref.read(authProvider).userRole == 'Teacher' || ref.read(authProvider).userRole == 'SystemAdmin')
                                  ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await ref.read(dioProvider).post('/payments/manual-cash', data: {'monthlyFeeObligationId': ob.id});
                                        ref.read(feeObligationsProvider.notifier).loadObligations();
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as Cash Paid!')));
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                    child: const Text('Cash Paid', style: TextStyle(color: Colors.white)),
                                  ),
                              ],
                            )
                          : Chip(
                              label: Text(ob.status),
                              backgroundColor: ob.status == 'Paid' 
                                  ? AppColors.success.withOpacity(0.2) 
                                  : AppColors.warning.withOpacity(0.2),
                            ),
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
