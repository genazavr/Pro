import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../theme/app_theme.dart';
import 'animated_background.dart';

class ThemedPage extends StatefulWidget {
  final Widget child;
  final String? userId;
  final bool useAnimatedBackground;

  const ThemedPage({
    super.key,
    required this.child,
    this.userId,
    this.useAnimatedBackground = true,
  });

  @override
  State<ThemedPage> createState() => _ThemedPageState();
}

class _ThemedPageState extends State<ThemedPage> {
  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ThemeManager>().initialize(widget.userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        if (widget.useAnimatedBackground) {
          return AnimatedBackground(
            theme: themeManager.currentTheme,
            child: widget.child,
          );
        } else {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.getBackgroundColor(themeManager.currentTheme),
                  AppTheme.getBackgroundColor(themeManager.currentTheme).withValues(alpha: 0.8),
                  AppTheme.getSurfaceColor(themeManager.currentTheme).withValues(alpha: 0.6),
                ],
              ),
            ),
            child: widget.child,
          );
        }
      },
    );
  }
}