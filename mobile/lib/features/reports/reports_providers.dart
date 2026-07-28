import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';
import 'profit_loss_report.dart';
import 'reports_repository.dart';

final reportsRepositoryProvider = Provider(
  (ref) => ReportsRepository(ref.watch(apiClientProvider)),
);

class ProfitLossController extends AsyncNotifier<ProfitLossReport> {
  @override
  Future<ProfitLossReport> build() {
    return ref.read(reportsRepositoryProvider).fetchProfitLoss();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(reportsRepositoryProvider).fetchProfitLoss());
  }
}

final profitLossControllerProvider = AsyncNotifierProvider<ProfitLossController, ProfitLossReport>(
  ProfitLossController.new,
);
