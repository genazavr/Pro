import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../theme/animated_background.dart';

class ThemedPage extends StatelessWidget {
  final Widget child;
  final bool useAnimatedBackground;
  final Color? backgroundColor;

  const ThemedPage({
    super.key,
    required this.child,
    this.useAnimatedBackground = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    if (!useAnimatedBackground) {
      return child;
    }

    return AnimatedBackground(
      theme: themeManager.currentTheme,
      child: Container(
        color: backgroundColor?.withValues(alpha: 0.1),
        child: child,
      ),
    );
  }
}