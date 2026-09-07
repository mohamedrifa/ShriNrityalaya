import 'package:dio/dio.dart';
import '../domain/models/monthly_fee_obligation.dart';

class FeeObligationsRepository {
  final Dio _dio;

  FeeObligationsRepository(this._dio);

  Future<List<MonthlyFeeObligation>> getObligations() async {
    final response = await _dio.get('/MonthlyFeeObligations');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((e) => MonthlyFeeObligation.fromJson(e)).toList();
    }
    throw Exception('Failed to load obligations');
  }

  Future<void> generateObligations(int year, int month) async {
    final response = await _dio.post('/MonthlyFeeObligations/generate?year=$year&month=$month');
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception('Failed to generate obligations');
    }
  }
}
