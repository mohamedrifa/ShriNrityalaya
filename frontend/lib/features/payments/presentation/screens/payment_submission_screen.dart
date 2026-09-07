import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:shri_nrityalaya_app/features/fees/domain/models/monthly_fee_obligation.dart';
import 'package:shri_nrityalaya_app/features/fees/presentation/providers/fee_obligations_providers.dart';
import '../../../../core/network/api_client.dart';

class PaymentSubmissionScreen extends ConsumerStatefulWidget {
  final MonthlyFeeObligation obligation;

  const PaymentSubmissionScreen({Key? key, required this.obligation}) : super(key: key);

  @override
  ConsumerState<PaymentSubmissionScreen> createState() => _PaymentSubmissionScreenState();
}

class _PaymentSubmissionScreenState extends ConsumerState<PaymentSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _transactionRefController = TextEditingController();
  String _paymentMethod = 'UPI';
  File? _imageFile;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter transaction reference and upload a screenshot')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dio = ref.read(dioProvider);
      
      final formData = FormData.fromMap({
        'studentId': widget.obligation.studentId,
        'monthlyFeeObligationId': widget.obligation.id,
        'amount': widget.obligation.amountDue,
        'paymentMethod': _paymentMethod,
        'transactionReference': _transactionRefController.text.trim(),
        'proofImage': await MultipartFile.fromFile(_imageFile!.path, filename: 'proof.jpg'),
      });

      final response = await dio.post('/payments/submit-proof', data: formData);

      if (response.statusCode == 200) {
        // Refresh obligations so the parent sees it as Under Review
        await ref.read(feeObligationsProvider.notifier).loadObligations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment proof submitted successfully!')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Submit Payment'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Amount Due:', style: TextStyle(fontSize: 16, color: AppColors.mutedText)),
                                Text('\$${widget.obligation.amountDue}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('For Month:', style: TextStyle(fontSize: 16, color: AppColors.mutedText)),
                                Text('${widget.obligation.month}/${widget.obligation.year}', style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                      items: ['UPI', 'BankTransfer', 'Cash'].map((m) {
                        return DropdownMenuItem(value: m, child: Text(m));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _paymentMethod = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _transactionRefController,
                      decoration: const InputDecoration(
                        labelText: 'Transaction Reference ID',
                        border: OutlineInputBorder(),
                        hintText: 'e.g. UPI Ref Number',
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text('Payment Screenshot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.primaryNavy, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _imageFile == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload, size: 50, color: AppColors.primaryGold),
                                  SizedBox(height: 8),
                                  Text('Tap to select image', style: TextStyle(color: AppColors.mutedText)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              ),
                      ),
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
                        onPressed: _submitPayment,
                        child: const Text('Submit Proof', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
