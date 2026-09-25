import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/network/api_client.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:shri_nrityalaya_app/features/fees/domain/models/monthly_fee_obligation.dart';

class PaymentDetailsScreen extends ConsumerStatefulWidget {
  final MonthlyFeeObligation obligation;

  const PaymentDetailsScreen({Key? key, required this.obligation}) : super(key: key);

  @override
  ConsumerState<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends ConsumerState<PaymentDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _paymentData;

  @override
  void initState() {
    super.initState();
    _fetchPayment();
  }

  Future<void> _fetchPayment() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/payments/obligation/${widget.obligation.id}');
      if (response.statusCode == 200) {
        setState(() {
          _paymentData = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Payment Details'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _paymentData == null
              ? const Center(child: Text('Payment details not found.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Submitted Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRow('Amount', '\$${_paymentData!['amount']}'),
                              const Divider(),
                              _buildRow('Payment Method', _paymentData!['paymentMethod'] ?? 'N/A'),
                              const Divider(),
                              _buildRow('Transaction Ref', _paymentData!['transactionReference'] ?? 'N/A'),
                              const Divider(),
                              _buildRow('Status', _paymentData!['status'] ?? 'N/A'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_paymentData!['proofImageUrl'] != null) ...[
                        const Text('Payment Screenshot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryNavy, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              '${ref.read(dioProvider).options.baseUrl.replaceAll('/api/v1', '')}${_paymentData!['proofImageUrl']}',
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Icon(Icons.broken_image, size: 50, color: AppColors.mutedText),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: AppColors.primaryNavy,
                          ),
                          onPressed: () {
                            context.pushReplacement('/payments/submit', extra: widget.obligation);
                          },
                          child: const Text('Resubmit Payment Proof', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.mutedText, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
