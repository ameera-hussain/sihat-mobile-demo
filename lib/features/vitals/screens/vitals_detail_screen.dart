import 'package:flutter/material.dart';
import '../models/vitals_reading.dart';
import '../../../core/constants/app_decorations.dart';

class VitalsDetailScreen extends StatelessWidget {
  final VitalsReading reading;
  const VitalsDetailScreen({super.key, required this.reading});

  bool get _isActivityReading => reading.type.toLowerCase() == 'activity';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(reading.type)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusBanner(status: reading.status),
            const SizedBox(height: 24),
            if (_isActivityReading)
              _ActivityMetricsRow(metrics: _extractActivityMetrics())
            else
              _InfoRow(label: 'Value', value: '${reading.value} ${reading.unit}'),
            _InfoRow(label: 'Recorded', value: _formatDate(reading.date)),
            if (reading.note != null) ...[
              const SizedBox(height: 16),
              Text('Note', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(reading.note!),
            ],
            const SizedBox(height: 32),
            /// BACKEND: replace with a real chart once readings are available from API
            const _PlaceholderChart(),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}'
        ' at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  List<_ActivityMetric> _extractActivityMetrics() {
    final source = '${reading.value} ${reading.unit} ${reading.note ?? ''}';

    String? findWithRegex(RegExp pattern, int group) {
      final match = pattern.firstMatch(source);
      return match?.group(group);
    }

    final distanceValue =
        findWithRegex(RegExp(r'(\d+(?:\.\d+)?)\s*(km|m)\b', caseSensitive: false), 1);
    final distanceUnit =
        findWithRegex(RegExp(r'(\d+(?:\.\d+)?)\s*(km|m)\b', caseSensitive: false), 2);

    final stepsValue =
        findWithRegex(RegExp(r'(\d[\d,]*)\s*steps?\b', caseSensitive: false), 1) ??
            findWithRegex(RegExp(r'steps?\s*[:=-]?\s*(\d[\d,]*)', caseSensitive: false), 1);

    final caloriesValue =
        findWithRegex(RegExp(r'(\d+(?:\.\d+)?)\s*(kcal|cal(?:ories)?)\b', caseSensitive: false), 1) ??
            findWithRegex(RegExp(r'cal(?:ories)?\s*[:=-]?\s*(\d+(?:\.\d+)?)', caseSensitive: false), 1);
    final caloriesUnit =
        findWithRegex(RegExp(r'(\d+(?:\.\d+)?)\s*(kcal|cal(?:ories)?)\b', caseSensitive: false), 2) ??
            'kcal';

    return [
      _ActivityMetric(
        label: 'Distance',
        value: distanceValue ?? '--',
        unit: distanceValue == null ? '' : (distanceUnit ?? 'km'),
      ),
      _ActivityMetric(
        label: 'Steps',
        value: stepsValue ?? '--',
        unit: '',
      ),
      _ActivityMetric(
        label: 'Calories',
        value: caloriesValue ?? '--',
        unit: caloriesValue == null ? '' : caloriesUnit,
      ),
    ];
  }
}

class _ActivityMetric {
  final String label;
  final String value;
  final String unit;

  const _ActivityMetric({
    required this.label,
    required this.value,
    required this.unit,
  });
}

class _ActivityMetricsRow extends StatelessWidget {
  final List<_ActivityMetric> metrics;
  const _ActivityMetricsRow({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          for (var i = 0; i < metrics.length; i++) ...[
            Expanded(child: _ActivityMetricBox(metric: metrics[i])),
            if (i != metrics.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _ActivityMetricBox extends StatelessWidget {
  final _ActivityMetric metric;
  const _ActivityMetricBox({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            metric.unit.isEmpty ? metric.value : '${metric.value} ${metric.unit}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

//  Status banner 

class _StatusBanner extends StatelessWidget {
  final VitalsStatus status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      VitalsStatus.normal => (Colors.green, 'Normal'),
      VitalsStatus.warning => (Colors.orange, 'Needs attention'),
      VitalsStatus.critical => (Colors.red, 'Critical — consult your doctor'),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: cardDecoration,
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

//  Info row 

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

//  Chart placeholder 

class _PlaceholderChart extends StatelessWidget {
  const _PlaceholderChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: cardDecoration,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 36, color: Theme.of(context).disabledColor),
            const SizedBox(height: 8),
            Text(
              'Historical chart — coming once API is connected',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
