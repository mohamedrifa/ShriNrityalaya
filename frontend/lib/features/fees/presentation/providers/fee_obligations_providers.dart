import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/fee_obligations_repository.dart';
import '../../domain/models/monthly_fee_obligation.dart';

final feeObligationsRepositoryProvider = Provider<FeeObligationsRepository>((ref) {
  return FeeObligationsRepository(ref.watch(dioProvider));
});

final feeObligationsProvider = StateNotifierProvider.autoDispose<FeeObligationsNotifier, AsyncValue<List<MonthlyFeeObligation>>>((ref) {
  final auth = ref.watch(authProvider);
  return FeeObligationsNotifier(
    ref.watch(feeObligationsRepositoryProvider),
    isAuthenticated: auth.isAuthenticated,
  );
});

class FeeObligationsNotifier extends StateNotifier<AsyncValue<List<MonthlyFeeObligation>>> {
  final FeeObligationsRepository _repository;
  final bool isAuthenticated;

  FeeObligationsNotifier(this._repository, {this.isAuthenticated = true}) : super(const AsyncValue.loading()) {
    if (isAuthenticated) {
      loadObligations();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadObligations() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      final obligations = await _repository.getObligations();
      if (!mounted) return;
      state = AsyncValue.data(obligations);
    } catch (e, stack) {
      if (!mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> generateObligations(int year, int month) async {
    try {
      await _repository.generateObligations(year, month);
      if (!mounted) return;
      await loadObligations(); // Reload list after generating
    } catch (e) {
      rethrow;
    }
  }
}
