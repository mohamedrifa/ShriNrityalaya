import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/messaging_repository.dart';
import '../../domain/models/announcement.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MessagingRepository(ref.watch(dioProvider));
});

final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final repo = ref.watch(messagingRepositoryProvider);
  return await repo.getAnnouncements();
});
