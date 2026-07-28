import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import 'profit_loss_report.dart';

class ReportsRepository {
  ReportsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ProfitLossReport> fetchProfitLoss() async {
    try {
      final response = await _apiClient.dio.get('/reports/profit-loss');
      return ProfitLossReport.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _apiClient.toApiException(error);
    }
  }
}
