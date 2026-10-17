import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import '../../../../core/network/api_client.dart';
import '../providers/fee_plans_providers.dart';

class FeePlanFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? feePlan;

  const FeePlanFormScreen({super.key, this.feePlan});

  @override
  ConsumerState<FeePlanFormScreen> createState() => _FeePlanFormScreenState();
}

class _FeePlanFormScreenState extends ConsumerState<FeePlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _monthlyAmountController;
  late TextEditingController _admissionFeeController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.feePlan?['name'] ?? '');
    _monthlyAmountController = TextEditingController(
      text: widget.feePlan?['monthlyAmount']?.toString() ?? '',
    );
    _admissionFeeController = TextEditingController(
      text: widget.feePlan?['admissionFee']?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.feePlan?['description'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _monthlyAmountController.dispose();
    _admissionFeeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text,
      'monthlyAmount': double.tryParse(_monthlyAmountController.text) ?? 0,
      'admissionFee': double.tryParse(_admissionFeeController.text) ?? 0,
      'description': _descriptionController.text,
      'isActive': true,
    };

    try {
      final dio = ref.read(dioProvider);
      if (widget.feePlan == null) {
        await dio.post('/feeplans', data: data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plan created successfully!')),
          );
        }
      } else {
        await dio.put('/feeplans/${widget.feePlan!['id']}', data: data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plan updated successfully!')),
          );
        }
      }
      ref.invalidate(feePlansProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textMutedSlate, fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: AppColors.goldOchreDeep),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.goldAccentLight, width: 1.3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.navyDarkPill, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.crimsonAbsent, width: 1.3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.crimsonAbsent, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.feePlan != null;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navyHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEdit ? 'Edit Fee Plan' : 'Create Fee Plan',
          style: const TextStyle(
            color: AppColors.goldBright,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: _buildInputDecoration(
                          'Plan Name (e.g. Beginner Monthly)',
                          Icons.workspace_premium_outlined,
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _monthlyAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _buildInputDecoration(
                          'Monthly Amount (₹)',
                          Icons.currency_rupee,
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _admissionFeeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: _buildInputDecoration(
                          'Admission Fee (₹)',
                          Icons.account_balance_wallet_outlined,
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: _buildInputDecoration(
                          'Description',
                          Icons.description_outlined,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navyDarkPill,
                            foregroundColor: AppColors.goldBright,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: AppColors.goldBorder, width: 1.4),
                            ),
                          ),
                          onPressed: _submit,
                          child: Text(
                            isEdit ? 'Update Plan' : 'Save Plan',
                            style: const TextStyle(
                              color: AppColors.goldBright,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
