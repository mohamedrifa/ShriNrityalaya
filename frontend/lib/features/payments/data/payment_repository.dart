import 'package:dio/dio.dart';
import '../domain/models/payment_record.dart';

class PaymentRepository {
  final Dio _dio;

  PaymentRepository(this._dio);

  Future<PaymentRecord> submitPayment({
    required String obligationId,
    required num amount,
    required String paymentMethod,
    required String transactionReference,
  }) async {
    final response = await _dio.post(
      '/payments',
      data: {
        'obligationId': obligationId,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'transactionReference': transactionReference,
      },
    );
    return PaymentRecord.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
