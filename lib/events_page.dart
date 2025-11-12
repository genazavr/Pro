import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/themed_page.dart';
import '../services/event_service.dart';
import '../models/event.dart';

class EventsPage extends StatefulWidget {
  final String userId;
  final String userName;

  const EventsPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final EventService _eventService = EventService();
  List<Event> _events = [];
  List<Event> _myEvents = [];
  bool _isLoading = true;
  bool _canCreateEvent = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final events = await _eventService.getActiveEvents();
      final myEvents = await _eventService.getUserCreatedEvents(widget.userId);
      final canCreate = await _eventService.canCreateEvent(widget.userId);
      
      setState(() {
        _events = events;
        _myEvents = myEvents;
        _canCreateEvent = canCreate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Ошибка загрузки мероприятий: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemedPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent.withValues(alpha: 0.8),
          title: Text('Мероприятия', style: GoogleFonts.montserrat()),
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCreateButton(),
                    const SizedBox(height: 20),
                    _buildMyEventsSection(),
                    const SizedBox(height: 20),
                    _buildAvailableEventsSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Card(
      color: Colors.white.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _canCreateEvent
                  ? 'Вы можете создать мероприятие'
                  : 'Вы можете создать только одно мероприятие в неделю',
              style: GoogleFonts.montserrat(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _canCreateEvent ? () => _navigateToCreateEvent() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text('Создать мероприятие', style: GoogleFonts.montserrat()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyEventsSection() {
    final activeMyEvents = _myEvents.where((e) => e.isActive).toList();
    
    if (activeMyEvents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Мои мероприятия', style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 12),
        ...activeMyEvents.map((event) => _buildEventCard(event, isCreator: true)),
      ],
    );
  }

  Widget _buildAvailableEventsSection() {
    final availableEvents = _events
        .where((e) => e.creatorId != widget.userId && e.isActive)
        .toList();

    if (availableEvents.isEmpty) {
      return Center(
        child: Text(
          'Нет доступных мероприятий',
          style: GoogleFonts.montserrat(fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Доступные мероприятия', style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 12),
        ...availableEvents.map((event) => _buildEventCard(event)),
      ],
    );
  }

  Widget _buildEventCard(Event event, {bool isCreator = false}) {
    final isParticipant = event.participants
        .any((p) => p.userId == widget.userId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCreator)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _showDeleteDialog(event),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(event.description, style: GoogleFonts.montserrat()),
            const SizedBox(height: 8),
            Text('📍 ${event.location}', style: GoogleFonts.montserrat()),
            Text('📅 ${_formatDate(event.dateTime)}', style: GoogleFonts.montserrat()),
            Text('👤 Организатор: ${event.creatorName}', style: GoogleFonts.montserrat()),
            Text('👥 Участников: ${event.participants.length}', style: GoogleFonts.montserrat()),
            if (!isCreator && !isParticipant)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  onPressed: () => _joinEvent(event),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: Text('Принять участие', style: GoogleFonts.montserrat()),
                ),
              ),
            if (isParticipant)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Вы участвуете',
                    style: GoogleFonts.montserrat(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventPage(
          userId: widget.userId,
          userName: widget.userName,
          onEventCreated: _loadData,
        ),
      ),
    );
  }

  Future<void> _joinEvent(Event event) async {
    try {
      final participant = EventParticipant(
        userId: widget.userId,
        fullName: widget.userName,
        joinedAt: DateTime.now(),
      );

      await _eventService.joinEvent(event.id, participant);
      _loadData();
      _showError('Вы успешно присоединились к мероприятию!');
    } catch (e) {
      _showError('Ошибка при присоединении: $e');
    }
  }

  void _showDeleteDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удаление мероприятия', style: GoogleFonts.montserrat()),
        content: Text(
          'При удалении мероприятия вам нужно будет оценить каждого участника. Продолжить?',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена', style: GoogleFonts.montserrat()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToRatingPage(event);
            },
            child: Text('Продолжить', style: GoogleFonts.montserrat()),
          ),
        ],
      ),
    );
  }

  void _navigateToRatingPage(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventRatingPage(
          event: event,
          onRatingComplete: () async {
            await _eventService.deleteEvent(event.id);
            _loadData();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}