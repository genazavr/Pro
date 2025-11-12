import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userId;
  const BottomNav({super.key, required this.currentIndex, required this.onTap, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F2D),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.blueAccent.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.psychology_outlined,
                    label: "Тесты",
                    isActive: currentIndex == 0,
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.school_outlined,
                    label: "Вузы",
                    isActive: currentIndex == 1,
                  ),
                  const SizedBox(width: 60), // Space for center button
                  _buildNavItem(
                    index: 3,
                    icon: Icons.work_outline,
                    label: "Профессии",
                    isActive: currentIndex == 3,
                  ),
                  _buildNavItem(
                    index: 4,
                    icon: Icons.person_outline,
                    label: "Профиль",
                    isActive: currentIndex == 4,
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => onTap(2),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFEF3124),
                            const Color(0xFFEF3124).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF3124).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 28,
                            color: currentIndex == 2 ? Colors.white : Colors.white70,
                          ),
                          if (currentIndex == 2)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Icon(
                                Icons.chat_bubble_outline,
                                size: 28,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blueAccent.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(
            color: Colors.blueAccent.withValues(alpha: 0.5),
            width: 1,
          )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Иконка с эффектом свечения для активного состояния
            Stack(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isActive ? Colors.yellow : Colors.white70,
                ),
                if (isActive)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Icon(
                      icon,
                      size: 24,
                      color: Colors.yellow.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.yellow : Colors.white70,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}