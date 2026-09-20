import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final feePlansProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/feeplans');
  if (response.statusCode == 200) {
    return response.data['data'] as List<dynamic>;
  }
  throw Exception('Failed to load fee plans');
});
