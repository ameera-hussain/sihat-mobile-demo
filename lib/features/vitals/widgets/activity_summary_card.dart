import 'package:flutter/material.dart';
import '../../dashboard/models/dashboard_readings.dart';
import '../../../core/constants/app_decorations.dart';

class ActivitySummaryCard extends StatelessWidget {
  final List<DashboardActivityMetric> metrics;
  const ActivitySummaryCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Metrics spread horizontally
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < metrics.length; i++) ...[
                  ActivityMetricItem(
                    metric: metrics[i],
                    ringColor: _getRingColor(i),
                  ),
                  if (i < metrics.length - 1)
                    Container(
                      width: 1,
                      height: 60,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Activity rings progress indicator
          SizedBox(
            width: 110,
            height: 110,
            child: ActivityRingsIndicator(metrics: metrics),
          ),
        ],
      ),
    );
  }

  Color _getRingColor(int index) {
    // Distance (blue), Steps (green), Calories (red)
    const colors = [
      Color(0xFF00A8E8), // Distance - Blue
      Color(0xFF34C759), // Steps - Green
      Color(0xFFCD3B3B), // Calories - Red
    ];
    return colors[index];
  }
}

class ActivityMetricItem extends StatelessWidget {
  final DashboardActivityMetric metric;
  final Color ringColor;

  const ActivityMetricItem({
    super.key,
    required this.metric,
    required this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          metric.icon,
          color: ringColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          metric.value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ringColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          metric.label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class ActivityRingsIndicator extends StatelessWidget {
  final List<DashboardActivityMetric> metrics;

  const ActivityRingsIndicator({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ActivityRingsPainter(
        ringColors: const [
          Color(0xFF00A8E8), // Blue for Distance
          Color(0xFF34C759), // Green for Steps
          Color(0xFFCD3B3B), // Red for Calories
        ],
        progress: [0.7, 0.6, 0.5],
      ),
      child: const Center(
        child: SizedBox.expand(),
      ),
    );
  }
}

class ActivityRingsPainter extends CustomPainter {
  final List<Color> ringColors;
  final List<double> progress; // 0.0 to 1.0

  ActivityRingsPainter({
    required this.ringColors,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const gap = 4.0;
    const strokeWidth = 12.0; // Fatter rings

    // Draw three concentric rings
    for (int i = 0; i < ringColors.length; i++) {
      final radius = (size.width / 2) - (i * (strokeWidth + gap)) - strokeWidth;

      if (radius <= 0) continue;

      // Background ring
      final backgroundPaint = Paint()
        ..color = ringColors[i].withValues(alpha: 0.2)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(center, radius, backgroundPaint);

      // Progress ring
      final progressPaint = Paint()
        ..color = ringColors[i]
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final sweepAngle = 2 * 3.14159 * progress[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ActivityRingsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColors != ringColors;
  }
}