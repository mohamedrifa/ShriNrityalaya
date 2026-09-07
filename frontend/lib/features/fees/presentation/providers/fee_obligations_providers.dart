import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';
import '../../data/fee_obligations_repository.dart';
import '../../domain/models/monthly_fee_obligation.dart';

final feeObligationsRepositoryProvider = Provider<FeeObligationsRepository>((ref) {
  return FeeObligationsRepository(ref.watch(dioProvider));
});

final feeObligationsProvider = StateNotifierProvider<FeeObligationsNotifier, AsyncValue<List<MonthlyFeeObligation>>>((ref) {
  return FeeObligationsNotifier(ref.watch(feeObligationsRepositoryProvider));
});

class FeeObligationsNotifier extends StateNotifier<AsyncValue<List<MonthlyFeeObligation>>> {
  final FeeObligationsRepository _repository;

  FeeObligationsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadObligations();
  }

  Future<void> loadObligations() async {
    state = const AsyncValue.loading();
    try {
      final obligations = await _repository.getObligations();
      state = AsyncValue.data(obligations);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> generateObligations(int year, int month) async {
    try {
      await _repository.generateObligations(year, month);
      await loadObligations(); // Reload list after generating
    } catch (e) {
      rethrow;
    }
  }
}
