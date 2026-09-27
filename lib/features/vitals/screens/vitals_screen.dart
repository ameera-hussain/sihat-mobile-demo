import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vitals_provider.dart';
import '../models/vitals_reading.dart';
import '../widgets/vitals_reading_card.dart';
import '../widgets/document_upload_widget.dart';
import 'vitals_detail_screen.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../widgets/activity_summary_card.dart';
import '../../../core/constants/app_decorations.dart';
import '../widgets/connect_wearable_card.dart';

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VitalsProvider>().fetchVitals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VitalsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Text(
                    'My Vitals',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: cardDecoration,
                child: TabBar(
                  controller: _tabController,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Readings'),
                    Tab(text: 'Documents'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ReadingsTab(provider: provider),
                  _DocumentsTab(provider: provider),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
  style: FilledButton.styleFrom(
    backgroundColor: const Color(0xFF5D53A3),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
  onPressed: () => _showAddReadingSheet(context),
  icon: const Icon(Icons.add),
  label: const Text(
    'Log Vital',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
),
                ),
              ),
        
          ],
        );
      },
    );
  }

  void _showAddReadingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddReadingSheet(),
    );
  }
}

// Readings tab

class _ReadingsTab extends StatelessWidget {
  final VitalsProvider provider;
  const _ReadingsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const ConnectWearableCard(),
            const SizedBox(height: 20),
            const Text(
              'Activity Summary',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            ),
            const SizedBox(height: 12),
            ActivitySummaryCard(metrics: dashboardProvider.activityMetrics),
            const SizedBox(height: 20),
            const Text(
              'Vitals',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            ),
            const SizedBox(height: 12),
            if (provider.readings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No readings yet. Tap + to log one.')),
              )
            else
              ...provider.readings.map(
                (reading) => VitalsReadingCard(
                  reading: reading,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VitalsDetailScreen(reading: reading),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// Documents tab

class _DocumentsTab extends StatelessWidget {
  final VitalsProvider provider;
  const _DocumentsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DocumentUploadWidget(
          onUpload: (fileName, fileType) =>
              context.read<VitalsProvider>().uploadDocument(fileName, fileType),
        ),
        const SizedBox(height: 16),
        ...provider.documents.map(
          (doc) => _DocumentTile(
            doc: doc,
            onDelete: () =>
                context.read<VitalsProvider>().deleteDocument(doc.id),
          ),
        ),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final MedicalDocument doc;
  final VoidCallback onDelete;
  const _DocumentTile({required this.doc, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        doc.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.image,
        color: doc.fileType == 'pdf' ? Colors.red : Colors.blue,
      ),
      title: Text(doc.fileName),
      subtitle: Text(
        'Uploaded ${_formatDate(doc.uploadedAt)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: onDelete,
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

// Add reading bottom sheet

class _AddReadingSheet extends StatefulWidget {
  const _AddReadingSheet();

  @override
  State<_AddReadingSheet> createState() => _AddReadingSheetState();
}

class _AddReadingSheetState extends State<_AddReadingSheet> {
  final _valueController = TextEditingController();
  String _selectedType = 'Blood Pressure';

  static const _types = [
    'Blood Pressure',
    'Heart Rate',
    'Blood Sugar',
    'SpO2',
    'Temperature',
  ];

  static const _units = {
    'Blood Pressure': 'mmHg',
    'Heart Rate': 'bpm',
    'Blood Sugar': 'mmol/L',
    'SpO2': '%',
    'Temperature': '°C',
  };

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log a vital', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            items: _types
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedType = v!),
            decoration: const InputDecoration(labelText: 'Type'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valueController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Value',
              suffixText: _units[_selectedType],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
  style: FilledButton.styleFrom(
    backgroundColor: const Color(0xFF5D53A3),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
  onPressed: () {
    // TODO (backend): add validation + wire to provider.addReading()
    Navigator.pop(context);
  },
  child: const Text(
    'Save reading',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
),
          ),
        ],
      ),
    );
  }
}
