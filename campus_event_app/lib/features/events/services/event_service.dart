import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class EventService {
  EventService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchCategories() {
    return _apiClient.get(ApiConstants.categories);
  }

  Future<Map<String, dynamic>> fetchEvents({
    String? search,
    int? categoryId,
    bool mine = false,
  }) {
    final query = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (categoryId != null) {
      query['category_id'] = categoryId.toString();
    }
    if (mine) {
      query['mine'] = '1';
    }
    return _apiClient.get(ApiConstants.events, queryParameters: query);
  }

  Future<Map<String, dynamic>> fetchEventDetail(int id) {
    return _apiClient.get(ApiConstants.eventDetail(id));
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> payload) {
    return _apiClient.post(ApiConstants.events, body: payload);
  }

  Future<Map<String, dynamic>> updateEvent(
      int id, Map<String, dynamic> payload) {
    return _apiClient.put(ApiConstants.eventDetail(id), body: payload);
  }

  Future<Map<String, dynamic>> cancelEvent(int id) {
    return _apiClient.delete(ApiConstants.eventDetail(id));
  }
}
