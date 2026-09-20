import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
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
    _monthlyAmountController = TextEditingController(text: widget.feePlan?['monthlyAmount']?.toString() ?? '');
    _admissionFeeController = TextEditingController(text: widget.feePlan?['admissionFee']?.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.feePlan?['description'] ?? '');
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
        // Create
        await dio.post('/feeplans', data: data);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan created successfully!')));
      } else {
        // Update
        await dio.put('/feeplans/${widget.feePlan!['id']}', data: data);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan updated successfully!')));
      }
      ref.invalidate(feePlansProvider);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: Text(widget.feePlan == null ? 'Create Fee Plan' : 'Edit Fee Plan'),
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
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Plan Name (e.g. Beginner Monthly)', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _monthlyAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Monthly Amount', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _admissionFeeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Admission Fee', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: _submit,
                        child: const Text('Save Plan', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
