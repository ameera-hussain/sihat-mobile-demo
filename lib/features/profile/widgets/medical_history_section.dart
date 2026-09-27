import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/my_profile_data.dart';
import '../providers/medical_history_provider.dart';
import 'section_header.dart';
import 'labeled_value.dart';

class MedicalHistorySection extends StatefulWidget {
  final List<MyMedicalHistory> entries;
  const MedicalHistorySection({super.key, required this.entries});

  @override
  State<MedicalHistorySection> createState() => _MedicalHistorySectionState();
}

class _EntryControllers {
  final TextEditingController condition;
  final TextEditingController diagnosisDate;
  final TextEditingController treatment;
  final TextEditingController notes;
  String id;

  _EntryControllers(MyMedicalHistory e)
      : id = e.id,
        condition = TextEditingController(text: e.condition),
        diagnosisDate = TextEditingController(text: e.diagnosisDate),
        treatment = TextEditingController(text: e.treatment),
        notes = TextEditingController(text: e.notes);

  MyMedicalHistory toModel() => MyMedicalHistory(
        id: id,
        condition: condition.text,
        diagnosisDate: diagnosisDate.text,
        treatment: treatment.text,
        notes: notes.text,
      );

  void dispose() {
    condition.dispose();
    diagnosisDate.dispose();
    treatment.dispose();
    notes.dispose();
  }
}

class _MedicalHistorySectionState extends State<MedicalHistorySection> {
  bool _isEditing = false;
  bool _isSaving = false;
  late List<_EntryControllers> _drafts;

  @override
  void initState() {
    super.initState();
    _drafts = widget.entries.map((e) => _EntryControllers(e)).toList();
  }

  void _resetDrafts() {
    for (final d in _drafts) {
      d.dispose();
    }
    _drafts = widget.entries.map((e) => _EntryControllers(e)).toList();
  }

  void _startEdit() => setState(() => _isEditing = true);

  void _cancelEdit() => setState(() {
        _resetDrafts();
        _isEditing = false;
      });

  void _addRow() => setState(() {
        _drafts.add(_EntryControllers(
          MyMedicalHistory(id: DateTime.now().microsecondsSinceEpoch.toString()),
        ));
      });

  void _removeRow(int index) => setState(() => _drafts.removeAt(index));

  Future<void> _saveEdit() async {
    setState(() => _isSaving = true);
    final updated = _drafts.map((d) => d.toModel()).toList();
    await context.read<MedicalHistoryProvider>().saveAll(updated);
    if (mounted) setState(() { _isSaving = false; _isEditing = false; });
  }

  @override
  void dispose() {
    for (final d in _drafts) {
      d.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Medical History',
          isEditing: _isEditing,
          onEditPressed: _startEdit,
          onCancelPressed: _isSaving ? null : _cancelEdit,
          onSavePressed: _isSaving ? null : _saveEdit,
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF5d53a3).withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isSaving)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: LinearProgressIndicator(),
                  ),
                if (!_isEditing) ..._buildViewRows() else ..._buildEditRows(),
                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: TextButton.icon(
                      onPressed: _addRow,
                      icon: const Icon(Icons.add),
                      label: const Text('Add condition'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildViewRows() {
    if (widget.entries.isEmpty) {
      return [Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Text('No medical history recorded.'))];
    }
    return widget.entries.asMap().entries.map((entry) {
      final idx = entry.key;
      final e = entry.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LabeledValue(label: 'Condition', value: e.condition),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LabeledValue(label: 'Diagnosed', value: e.diagnosisDate),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LabeledValue(label: 'Treatment', value: e.treatment),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LabeledValue(label: 'Notes', value: e.notes),
          ),
          if (idx < widget.entries.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: Colors.grey.shade300, thickness: 1),
            ),
        ],
      );
    }).toList();
  }

  List<Widget> _buildEditRows() {
    return List.generate(_drafts.length, (i) {
      final d = _drafts[i];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(child: TextFormField(controller: d.condition, decoration: const InputDecoration(labelText: 'Condition'))),
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _removeRow(i)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextFormField(
              controller: d.diagnosisDate,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Diagnosis Date'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(d.diagnosisDate.text) ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) d.diagnosisDate.text = picked.toIso8601String().split('T').first;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextFormField(controller: d.treatment, decoration: const InputDecoration(labelText: 'Treatment')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextFormField(controller: d.notes, decoration: const InputDecoration(labelText: 'Notes')),
          ),
          if (i < _drafts.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: Colors.grey.shade300, thickness: 1),
            ),
        ],
      );
    });
  }
}