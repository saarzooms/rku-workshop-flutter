import '../models/event_model.dart';
import '../services/event_service.dart';

class EventRepository {
  EventRepository(this._service);

  final EventService _service;

  Future<List<CategoryModel>> getCategories() async {
    final resp = await _service.fetchCategories();
    final list = (resp['data']?['categories'] as List?) ?? [];
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EventModel>> getEvents({
    String? search,
    int? categoryId,
    bool mine = false,
  }) async {
    final resp = await _service.fetchEvents(
      search: search,
      categoryId: categoryId,
      mine: mine,
    );
    final list = (resp['data']?['events'] as List?) ?? [];
    return list
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<EventModel> getEventDetail(int id) async {
    final resp = await _service.fetchEventDetail(id);
    return EventModel.fromJson(resp['data']['event'] as Map<String, dynamic>);
  }

  Future<EventModel> createEvent(Map<String, dynamic> payload) async {
    final resp = await _service.createEvent(payload);
    return EventModel.fromJson(resp['data']['event'] as Map<String, dynamic>);
  }

  Future<EventModel> updateEvent(int id, Map<String, dynamic> payload) async {
    final resp = await _service.updateEvent(id, payload);
    return EventModel.fromJson(resp['data']['event'] as Map<String, dynamic>);
  }

  Future<void> cancelEvent(int id) async {
    await _service.cancelEvent(id);
  }
}
