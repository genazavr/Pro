import 'package:firebase_database/firebase_database.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final String creatorId;
  final String creatorName;
  final List<EventParticipant> participants;
  final bool isActive;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.creatorId,
    required this.creatorName,
    required this.participants,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'dateTime': dateTime.toIso8601String(),
      'creatorId': creatorId,
      'creatorName': creatorName,
      'participants': participants.map((p) => p.toMap()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? '',
      participants: (map['participants'] as List<dynamic>?)
          ?.map((p) => EventParticipant.fromMap(p))
          .toList() ?? [],
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class EventParticipant {
  final String userId;
  final String fullName;
  final DateTime joinedAt;

  EventParticipant({
    required this.userId,
    required this.fullName,
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory EventParticipant.fromMap(Map<String, dynamic> map) {
    return EventParticipant(
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      joinedAt: DateTime.parse(map['joinedAt']),
    );
  }
}

class EventRating {
  final String eventId;
  final String participantId;
  final String participantName;
  final int stars;
  final DateTime ratedAt;

  EventRating({
    required this.eventId,
    required this.participantId,
    required this.participantName,
    required this.stars,
    required this.ratedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'participantId': participantId,
      'participantName': participantName,
      'stars': stars,
      'ratedAt': ratedAt.toIso8601String(),
    };
  }

  factory EventRating.fromMap(Map<String, dynamic> map) {
    return EventRating(
      eventId: map['eventId'] ?? '',
      participantId: map['participantId'] ?? '',
      participantName: map['participantName'] ?? '',
      stars: map['stars'] ?? 0,
      ratedAt: DateTime.parse(map['ratedAt']),
    );
  }
}