import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shri_nrityalaya_app/core/network/api_client.dart';
import 'package:shri_nrityalaya_app/features/events/data/event_repository.dart';
import 'package:shri_nrityalaya_app/features/events/domain/models/academy_event.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(dioProvider));
});

final eventsProvider = StateNotifierProvider<EventsNotifier, AsyncValue<List<AcademyEvent>>>((ref) {
  return EventsNotifier(ref.watch(eventRepositoryProvider));
});

class EventsNotifier extends StateNotifier<AsyncValue<List<AcademyEvent>>> {
  final EventRepository _repository;

  EventsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getEvents();
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createEvent(AcademyEvent event) async {
    try {
      final newEvent = await _repository.createEvent(event);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newEvent]);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent(AcademyEvent event) async {
    try {
      final updatedEvent = await _repository.updateEvent(event);
      if (state.hasValue) {
        final currentList = state.value!;
        final index = currentList.indexWhere((e) => e.id == updatedEvent.id);
        if (index != -1) {
          final newList = List<AcademyEvent>.from(currentList);
          newList[index] = updatedEvent;
          state = AsyncValue.data(newList);
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}
