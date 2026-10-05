import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Animated circular completion ring widget.
class CompletionRing extends StatefulWidget {
  final double progress; // 0.0 – 1.0
  final double size;
  final double strokeWidth;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const CompletionRing({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  State<CompletionRing> createState() => _CompletionRingState();
}

class _CompletionRingState extends State<CompletionRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
    _previousProgress = widget.progress;
  }

  @override
  void didUpdateWidget(CompletionRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
      _previousProgress = widget.progress;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _RingPainter(
              progress: _animation.value,
              strokeWidth: widget.strokeWidth,
              foregroundColor:
                  widget.foregroundColor ?? Theme.of(context).colorScheme.primary,
              backgroundColor:
                  widget.backgroundColor ?? Theme.of(context).dividerTheme.color!,
            ),
            child: Center(
              child: Text(
                '${(_animation.value * 100).toInt()}%',
                style: TextStyle(
                  fontSize: widget.size * 0.22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.displayLarge!.color!,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color foregroundColor;
  final Color backgroundColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0) {
      // Gradient sweep
      final rect = Rect.fromCircle(center: center, radius: radius);
      final shader = SweepGradient(
        colors: const [AppTheme.primary, AppTheme.emeraldDark],
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + (2 * math.pi * progress),
        tileMode: TileMode.clamp,
      ).createShader(rect);

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..shader = shader
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.foregroundColor != foregroundColor;
}




