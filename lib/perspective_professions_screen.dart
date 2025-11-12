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
                margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.3),
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
                            child: SizedBox(
                              height: MediaQuery.of(context).size.width * 0.11,
                              width: MediaQuery.of(context).size.width * 0.11,
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFF0A0F2D),
                                size: MediaQuery.of(context).size.width * 0.06,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            "Самые перспективные профессии",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: MediaQuery.of(context).size.width * 0.055,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0A0F2D),
                            ),
                          ),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.11),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                    Text(
                      "Высокий спрос и хорошая зарплата в Удмуртии",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: MediaQuery.of(context).size.width * 0.035,
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
                          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
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
                                  fontSize: MediaQuery.of(context).size.width * 0.045,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0A0F2D),
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.width * 0.05),
                              
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

              SizedBox(height: MediaQuery.of(context).size.width * 0.05),

              // Места обучения
              Container(
               margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
               padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
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
                       fontSize: MediaQuery.of(context).size.width * 0.045,
                       fontWeight: FontWeight.w700,
                       color: const Color(0xFF0A0F2D),
                     ),
                   ),
                   SizedBox(height: MediaQuery.of(context).size.width * 0.04),
                   Expanded(
                     child: SingleChildScrollView(
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           ...sortedProfessions.map((profession) => _buildEducationInfo(profession)),
                         ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
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
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A0F2D),
              ),
            ),
            Text(
              "Зарплата (₽)",
              style: GoogleFonts.nunito(
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A0F2D),
              ),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.04),
        
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
                margin: EdgeInsets.only(bottom: screenWidth * 0.05),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Название профессии
                    SizedBox(
                      width: screenWidth * 0.25,
                      child: Text(
                        profession['name'],
                        style: GoogleFonts.nunito(
                          fontSize: isSmallScreen ? 9 : 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A0F2D),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.04),

                    // График
                    Expanded(
                      child: SizedBox(
                        height: isSmallScreen ? 180 : 220,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Минимальная зарплата
                            Container(
                              width: screenWidth * 0.07,
                              height: minHeight,
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.6),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),

                            SizedBox(width: screenWidth * 0.005),

                            // Максимальная зарплата
                            Container(
                              width: screenWidth * 0.07,
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

                    SizedBox(width: screenWidth * 0.04),

                    // Значения зарплаты
                    SizedBox(
                      width: screenWidth * 0.15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            profession['salary'],
                            style: GoogleFonts.nunito(
                              fontSize: isSmallScreen ? 8 : 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6C63FF),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    _buildPlayButton(profession['name'], compact: true),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        
        // Легенда
        SizedBox(height: screenWidth * 0.04),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.04,
              height: screenWidth * 0.04,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              "Минимальная",
              style: GoogleFonts.nunito(
                fontSize: isSmallScreen ? 9 : 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0A0F2D),
              ),
            ),
            
            SizedBox(width: screenWidth * 0.06),
            
            Container(
              width: screenWidth * 0.04,
              height: screenWidth * 0.04,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              "Максимальная",
              style: GoogleFonts.nunito(
                fontSize: isSmallScreen ? 9 : 11,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
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
                size: isSmallScreen ? 18 : 20,
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  profession['name'],
                  style: GoogleFonts.nunito(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0A0F2D),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: screenWidth * 0.03),
          
          Text(
            "Учебные заведения:",
            style: GoogleFonts.nunito(
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6C63FF),
            ),
          ),
          
          SizedBox(height: screenWidth * 0.02),
          
          for (var college in profession['colleges'] as List)
            Padding(
              padding: EdgeInsets.only(bottom: screenWidth * 0.01),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.grey[600],
                    size: isSmallScreen ? 10 : 12,
                  ),
                  SizedBox(width: screenWidth * 0.015),
                  Expanded(
                    child: Text(
                      college,
                      style: GoogleFonts.nunito(
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0A0F2D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          SizedBox(height: screenWidth * 0.02),
          
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: Colors.green,
                size: isSmallScreen ? 14 : 16,
              ),
              SizedBox(width: screenWidth * 0.015),
              Text(
                "Зарплата: ${profession['salary']}",
                style: GoogleFonts.nunito(
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.03),
          Align(
            alignment: Alignment.centerRight,
            child: _buildPlayButton(profession['name']),
          ),
        ],
      ),
    );
  }
}