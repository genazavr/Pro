import 'package:firebase_database/firebase_database.dart';
import '../models/event.dart';

class EventService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<List<Event>> getActiveEvents() async {
    try {
      final snapshot = await _db.child('events')
          .orderByChild('isActive')
          .equalTo(true)
          .get();
      
      final events = <Event>[];
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          events.add(Event.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
      
      return events..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  Future<List<Event>> getUserCreatedEvents(String userId) async {
    try {
      final snapshot = await _db.child('events')
          .orderByChild('creatorId')
          .equalTo(userId)
          .get();
      
      final events = <Event>[];
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          events.add(Event.fromMap(Map<String, dynamic>.from(value), key));
        });
      }
      
      return events..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to load user events: $e');
    }
  }

  Future<bool> canCreateEvent(String userId) async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      
      final snapshot = await _db.child('events')
          .orderByChild('creatorId')
          .equalTo(userId)
          .get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        for (var value in data.values) {
          final eventData = Map<String, dynamic>.from(value);
          final createdAt = DateTime.parse(eventData['createdAt']);
          if (createdAt.isAfter(weekAgo)) {
            return false;
          }
        }
      }
      
      return true;
    } catch (e) {
      throw Exception('Failed to check event creation limit: $e');
    }
  }

  Future<String> createEvent(Event event) async {
    try {
      final eventRef = _db.child('events').push();
      await eventRef.set(event.toMap());
      return eventRef.key!;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<void> joinEvent(String eventId, EventParticipant participant) async {
    try {
      await _db.child('events/$eventId/participants').push().set(participant.toMap());
    } catch (e) {
      throw Exception('Failed to join event: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _db.child('events/$eventId').update({'isActive': false});
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  Future<void> rateParticipants(List<EventRating> ratings) async {
    try {
      for (final rating in ratings) {
        await _db.child('ratings').push().set(rating.toMap());
        await _updateUserStars(rating.participantId, rating.stars);
      }
    } catch (e) {
      throw Exception('Failed to save ratings: $e');
    }
  }

  Future<void> _updateUserStars(String userId, int stars) async {
    try {
      final snapshot = await _db.child('users/$userId/stars').get();
      final currentStars = snapshot.value as int? ?? 0;
      await _db.child('users/$userId/stars').set(currentStars + stars);
    } catch (e) {
      throw Exception('Failed to update user stars: $e');
    }
  }

  Future<int> getUserStars(String userId) async {
    try {
      final snapshot = await _db.child('users/$userId/stars').get();
      return snapshot.value as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> purchaseMerch(String userId, int cost) async {
    try {
      final stars = await getUserStars(userId);
      if (stars < cost) return false;
      
      await _db.child('users/$userId/stars').set(stars - cost);
      return true;
    } catch (e) {
      return false;
    }
  }
}