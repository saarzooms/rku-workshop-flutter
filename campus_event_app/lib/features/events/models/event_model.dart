class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.parse(json['id'].toString()),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }
}

class EventModel {
  const EventModel({
    required this.id,
    required this.organizerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.maxCapacity,
    required this.status,
    this.categoryName,
    this.organizerName,
    this.registeredCount = 0,
    this.isRegistered = false,
  });

  final int id;
  final int organizerId;
  final int categoryId;
  final String title;
  final String description;
  final String venue;
  final String startTime;
  final String endTime;
  final int maxCapacity;
  final String status;
  final String? categoryName;
  final String? organizerName;
  final int registeredCount;
  final bool isRegistered;

  bool get isFull => registeredCount >= maxCapacity;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: int.parse(json['id'].toString()),
      organizerId: int.parse(json['organizer_id'].toString()),
      categoryId: int.parse(json['category_id'].toString()),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      venue: (json['venue'] ?? '').toString(),
      startTime: (json['start_time'] ?? '').toString(),
      endTime: (json['end_time'] ?? '').toString(),
      maxCapacity: int.tryParse(json['max_capacity'].toString()) ?? 0,
      status: (json['status'] ?? 'published').toString(),
      categoryName: json['category_name']?.toString(),
      organizerName: json['organizer_name']?.toString(),
      registeredCount:
          int.tryParse(json['registered_count']?.toString() ?? '0') ?? 0,
      isRegistered: json['is_registered'] == true ||
          json['is_registered'].toString() == '1',
    );
  }
}
