import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'games/foundry_game.dart';
import 'games/qc_game.dart';
import 'games/stamper_game.dart';

class PerspectiveProfessionsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> perspectiveProfessions;
  final String userId;
  
  const PerspectiveProfessionsScreen({
    super.key, 
    required this.perspectiveProfessions,
    required this.userId,
  });

  @override
  State<PerspectiveProfessionsScreen> createState() => _PerspectiveProfessionsScreenState();
}

class _PerspectiveProfessionsScreenState extends State<PerspectiveProfessionsScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _parseMinSalary(String salary) {
    final match = RegExp(r'(\d+)').firstMatch(salary);
    return match != null ? int.parse(match.group(1)!) : 0;
  }

  int _parseMaxSalary(String salary) {
    final matches = RegExp(r'(\d+)').allMatches(salary).toList();
    return matches.length > 1 ? int.parse(matches[1].group(1)!) : 0;
  }

  void _handlePlay(String name) {
    Widget? gameScreen;
    
    switch (name) {
      case 'Литейщик':
        gameScreen = FoundryGame(userId: widget.userId);
        break;
      case 'Технический контролер':
        gameScreen = QCGame(userId: widget.userId);
        break;
      case 'Штамповщик':
        gameScreen = StamperGame(userId: widget.userId);
        break;
      default:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Игра для "$name" пока не доступна'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameScreen!),
    );
  }

  Widget _buildPlayButton(String name, {bool compact = false}) {
    final onTap = () => _handlePlay(name);
    if (compact) {
      return IconButton(
        onPressed: onTap,
        icon: const Icon(Icons.play_arrow_rounded),
        color: const Color(0xFF6C63FF),
        splashRadius: 22,
        tooltip: 'Играть',
      );
    }
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.play_arrow_rounded),
      label: const Text('Играть'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedProfessions = List<Map<String, dynamic>>.from(widget.perspectiveProfessions);
    sortedProfessions.sort((a, b) {
      final maxA = _parseMaxSalary(a['salary']);
      final maxB = _parseMaxSalary(b['salary']);
      return maxB.compareTo(maxA);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2D),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0F2D),
              const Color(0xFF1E3A8A).withOpacity(0.3),
              const Color(0xFF0A0F2D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Material(
                          color: const Color(0xFF6C63FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => Navigator.of(context).pop(),
                            child: const SizedBox(
                              height: 44,
                              width: 44,
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFF0A0F2D),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Самые перспективные профессии",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0A0F2D),
                            ),
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Высокий спрос и хорошая зарплата в Удмуртии",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                  ],
                ),
              ),

              // График зарплат
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "График заработных плат",
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0A0F2D),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // График
                              Expanded(
                                child: _buildSalaryChart(sortedProfessions),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Места обучения
              Container(
               height: 300,
               margin: const EdgeInsets.symmetric(horizontal: 20),
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 color: Colors.white.withOpacity(0.95),
                 borderRadius: BorderRadius.circular(20),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.1),
                     blurRadius: 15,
                     offset: const Offset(0, 5),
                   ),
                 ],
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     "Где учиться в Удмуртии",
                     style: GoogleFonts.nunito(
                       fontSize: 18,
                       fontWeight: FontWeight.w700,
                       color: const Color(0xFF0A0F2D),
                     ),
                   ),
                   const SizedBox(height: 16),
                   Expanded(
                     child: SingleChildScrollView(
                       child: Column(
                         children: sortedProfessions.map((profession) => _buildEducationInfo(profession)).toList(),
                       ),
                     ),
                   ),
                 ],
               ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryChart(List<Map<String, dynamic>> professions) {
    professions.map((p) => _parseMaxSalary(p['salary'])).reduce((a, b) => a > b ? a : b);
    
    return Column(
      children: [
        // Заголовок графика
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Профессия",
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A0F2D),
              ),
            ),
            Text(
              "Зарплата (₽)",
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A0F2D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Столбцы графика
        Expanded(
          child: Column(
            children: professions.asMap().entries.map((entry) {
              final profession = entry.value;
              final minSalary = _parseMinSalary(profession['salary']);
              final maxSalary = _parseMaxSalary(profession['salary']);
              final minHeight = (minSalary / maxSalary) * 200;
              final maxHeight = (maxSalary / maxSalary) * 200;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Название профессии
                    SizedBox(
                      width: 100,
                      child: Text(
                        profession['name'],
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A0F2D),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // График
                    Expanded(
                      child: SizedBox(
                        height: 220,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Минимальная зарплата
                            Container(
                              width: 30,
                              height: minHeight,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.6),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                            
                            const SizedBox(width: 2),
                            
                            // Максимальная зарплата
                            Container(
                              width: 30,
                              height: maxHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    const Color(0xFF6C63FF),
                                    const Color(0xFF4A90E2),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Значения зарплаты
                    SizedBox(
                      width: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            profession['salary'],
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6C63FF),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildPlayButton(profession['name'], compact: true),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        
        // Легенда
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Минимальная",
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A0F2D),
              ),
            ),
            
            const SizedBox(width: 24),
            
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Максимальная",
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A0F2D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEducationInfo(Map<String, dynamic> profession) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: const Color(0xFF6C63FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  profession['name'],
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A0F2D),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            "Учебные заведения:",
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6C63FF),
            ),
          ),
          
          const SizedBox(height: 8),
          
          for (var college in profession['colleges'] as List)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.grey[600],
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      college,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0A0F2D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: Colors.green,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                "Зарплата: ${profession['salary']}",
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _buildPlayButton(profession['name']),
          ),
        ],
      ),
    );
  }
}