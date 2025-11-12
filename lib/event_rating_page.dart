import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/themed_page.dart';
import '../services/event_service.dart';
import '../models/event.dart';

class EventRatingPage extends StatefulWidget {
  final Event event;
  final VoidCallback onRatingComplete;

  const EventRatingPage({
    super.key,
    required this.event,
    required this.onRatingComplete,
  });

  @override
  State<EventRatingPage> createState() => _EventRatingPageState();
}

class _EventRatingPageState extends State<EventRatingPage> {
  final EventService _eventService = EventService();
  final Map<String, int> _ratings = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (final participant in widget.event.participants) {
      _ratings[participant.userId] = 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent.withValues(alpha: 0.8),
          title: Text('Оценка участников', style: GoogleFonts.montserrat()),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                color: Colors.white.withValues(alpha: 0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Оцените каждого участника по шкале от 1 до 5 звезд',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...widget.event.participants.map((participant) => _buildParticipantCard(participant)),
              const SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantCard(EventParticipant participant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              participant.fullName,
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Оценка:', style: GoogleFonts.montserrat(fontSize: 16)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _ratings[participant.userId]!
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _ratings[participant.userId] = index + 1;
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
            Text(
              '${_ratings[participant.userId]} звезд',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRatings,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('Завершить оценку и удалить мероприятие', 
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
      ),
    );
  }

  Future<void> _submitRatings() async {
    setState(() => _isLoading = true);

    try {
      final ratings = widget.event.participants.map((participant) {
        return EventRating(
          eventId: widget.event.id,
          participantId: participant.userId,
          participantName: participant.fullName,
          stars: _ratings[participant.userId]!,
          ratedAt: DateTime.now(),
        );
      }).toList();

      await _eventService.rateParticipants(ratings);
      widget.onRatingComplete();
    } catch (e) {
      _showError('Ошибка при сохранении оценок: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}