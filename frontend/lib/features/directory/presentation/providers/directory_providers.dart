import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';

final directoryProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/directory');
  if (response.statusCode == 200 && response.data['success'] == true) {
    final List<dynamic> data = response.data['data'];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }
  throw Exception('Failed to load directory');
});
