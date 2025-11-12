import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../theme/app_theme.dart';

class ScheduleCalendarPage extends StatefulWidget {
  final String userId;
  const ScheduleCalendarPage({super.key, required this.userId});

  @override
  State<ScheduleCalendarPage> createState() => _ScheduleCalendarPageState();
}

class _ScheduleCalendarPageState extends State<ScheduleCalendarPage> {
  final _db = FirebaseDatabase.instance.ref();
  DateTime _selectedDate = DateTime.now();
  Map<String, List<ScheduleItem>> _schedules = {};

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final snap = await _db.child('users/${widget.userId}/schedules').get();
    if (snap.exists) {
      final data = snap.value as Map;
      final Map<String, List<ScheduleItem>> schedules = {};
      data.forEach((key, value) {
        final items = (value as Map).entries.map((e) {
          final item = e.value as Map;
          return ScheduleItem(
            id: e.key.toString(),
            title: item['title'] ?? '',
            time: item['time'] ?? '',
            description: item['description'] ?? '',
            color: Color(item['color'] ?? 0xFFEF3124),
          );
        }).toList();
        schedules[key] = items;
      });
      setState(() => _schedules = schedules);
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<ScheduleItem> _getSchedulesForDate(DateTime date) {
    return _schedules[_getDateKey(date)] ?? [];
  }

  void _addSchedule() {
    final titleController = TextEditingController();
    final timeController = TextEditingController(text: '09:00');
    final descController = TextEditingController();
    Color selectedColor = const Color(0xFFEF3124);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 24,
              right: 24,
              top: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Новая запись',
                    style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Название',
                      labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: timeController,
                    decoration: InputDecoration(
                      labelText: 'Время',
                      labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Описание',
                      labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Цвет:', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      ...[
                        const Color(0xFFEF3124),
                        Colors.blue,
                        Colors.green,
                        Colors.purple,
                        Colors.orange,
                      ].map((color) => GestureDetector(
                        onTap: () => setModalState(() => selectedColor = color),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        final dateKey = _getDateKey(_selectedDate);
                        final itemId = DateTime.now().millisecondsSinceEpoch.toString();
                        _db.child('users/${widget.userId}/schedules/$dateKey/$itemId').set({
                          'title': titleController.text,
                          'time': timeController.text,
                          'description': descController.text,
                          'color': selectedColor.value,
                        });
                        _loadSchedules();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF3124),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Добавить',
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteSchedule(String dateKey, String itemId) {
    _db.child('users/${widget.userId}/schedules/$dateKey/$itemId').remove();
    _loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;
    final schedules = _getSchedulesForDate(_selectedDate);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(theme),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryColor(theme)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Календарь расписания',
          style: GoogleFonts.nunito(
            color: AppTheme.getPrimaryColor(theme),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCalendar(theme),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.event_note, color: AppTheme.getPrimaryColor(theme)),
                const SizedBox(width: 8),
                Text(
                  '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getPrimaryColor(theme),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: schedules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Нет записей на эту дату',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: schedules.length,
                    itemBuilder: (ctx, i) => _buildScheduleCard(schedules[i], theme),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSchedule,
        backgroundColor: AppTheme.getPrimaryColor(theme),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendar(SeasonTheme theme) {
    final now = DateTime.now();
    final firstDay = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getPrimaryColor(theme).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                  });
                },
              ),
              Text(
                '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб']
                .map((day) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate((lastDay.day + startWeekday) ~/ 7 + 1, (week) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (day) {
                  final dayNum = week * 7 + day - startWeekday + 1;
                  if (dayNum < 1 || dayNum > lastDay.day) {
                    return const SizedBox(width: 40, height: 40);
                  }
                  final date = DateTime(_selectedDate.year, _selectedDate.month, dayNum);
                  final isSelected = date.day == _selectedDate.day &&
                      date.month == _selectedDate.month &&
                      date.year == _selectedDate.year;
                  final isToday = date.day == now.day &&
                      date.month == now.month &&
                      date.year == now.year;
                  final hasSchedule = _getSchedulesForDate(date).isNotEmpty;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.getPrimaryColor(theme)
                            : isToday
                                ? AppTheme.getPrimaryColor(theme).withOpacity(0.2)
                                : null,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            dayNum.toString(),
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          if (hasSchedule && !isSelected)
                            Positioned(
                              bottom: 4,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppTheme.getPrimaryColor(theme),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleItem item, SeasonTheme theme) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteSchedule(_getDateKey(_selectedDate), item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} удалено', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.red,
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color, width: 2),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0A0F2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        item.time,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];
    return months[month - 1];
  }
}

class ScheduleItem {
  final String id;
  final String title;
  final String time;
  final String description;
  final Color color;

  ScheduleItem({
    required this.id,
    required this.title,
    required this.time,
    required this.description,
    required this.color,
  });
}
