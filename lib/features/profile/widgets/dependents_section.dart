import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/my_dependent_data.dart';
import '../providers/dependents_provider.dart';
import 'section_header.dart';
import 'labeled_value.dart';

class DependentsSection extends StatefulWidget {
  final String guardianId;
  final List<MyDependent> dependents;
  const DependentsSection({super.key, required this.guardianId, required this.dependents});

  @override
  State<DependentsSection> createState() => _DependentsSectionState();
}

class _DependentDraft {
  String id;
  final TextEditingController name;
  final TextEditingController relationshipLabel;
  final TextEditingController dateOfBirth;
  DependentType dependentType;
  bool canViewFullProfile;

  _DependentDraft(MyDependent d)
      : id = d.id,
        name = TextEditingController(text: d.name),
        relationshipLabel = TextEditingController(text: d.relationshipLabel),
        dateOfBirth = TextEditingController(text: d.dateOfBirth),
        dependentType = d.dependentType,
        canViewFullProfile = d.canViewFullProfile;

  MyDependent toModel(String guardianId) => MyDependent(
        id: id,
        guardianId: guardianId,
        dependentType: dependentType,
        name: name.text,
        relationshipLabel: relationshipLabel.text,
        dateOfBirth: dateOfBirth.text,
        canViewFullProfile: canViewFullProfile,
      );

  void dispose() {
    name.dispose();
    relationshipLabel.dispose();
    dateOfBirth.dispose();
  }
}

class _DependentsSectionState extends State<DependentsSection> {
  bool _isEditing = false;
  bool _isSaving = false;
  late List<_DependentDraft> _drafts;

  @override
  void initState() {
    super.initState();
    _drafts = widget.dependents.map((d) => _DependentDraft(d)).toList();
  }

  void _resetDrafts() {
    for (final d in _drafts) {
      d.dispose();
    }
    _drafts = widget.dependents.map((d) => _DependentDraft(d)).toList();
  }

  void _addRow() => setState(() {
        _drafts.add(_DependentDraft(MyDependent(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          guardianId: widget.guardianId,
          dependentType: DependentType.child,
          name: '',
        )));
      });

  void _removeRow(int index) => setState(() => _drafts.removeAt(index));

  Future<void> _saveEdit() async {
    setState(() => _isSaving = true);
    final updated = _drafts.map((d) => d.toModel(widget.guardianId)).toList();
    await context.read<DependentsProvider>().saveAll(updated);
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
          title: 'Dependents',
          isEditing: _isEditing,
          onEditPressed: () => setState(() => _isEditing = true),
          onCancelPressed: _isSaving ? null : () => setState(() { _resetDrafts(); _isEditing = false; }),
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
                    child: TextButton.icon(onPressed: _addRow, icon: const Icon(Icons.add), label: const Text('Add dependent')),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildViewRows() {
    if (widget.dependents.isEmpty) {
      return [Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Text('No dependents added.'))];
    }
    return widget.dependents.asMap().entries.map((entry) {
      final idx = entry.key;
      final d = entry.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LabeledValue(label: 'Name', value: d.name),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LabeledValue(label: 'Relationship', value: d.relationshipLabel?.isNotEmpty == true ? d.relationshipLabel : d.dependentType.name),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LabeledValue(label: 'Date of Birth', value: d.dateOfBirth),
          ),
          if (idx < widget.dependents.length - 1)
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
                Expanded(child: TextFormField(controller: d.name, decoration: const InputDecoration(labelText: 'Name'))),
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
            child: DropdownButtonFormField<DependentType>(
              initialValue: d.dependentType,
              decoration: const InputDecoration(labelText: 'Relationship Type'),
              items: DependentType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
              onChanged: (v) => setState(() => d.dependentType = v ?? d.dependentType),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextFormField(controller: d.relationshipLabel, decoration: const InputDecoration(labelText: 'Custom Label (optional)')),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextFormField(
              controller: d.dateOfBirth,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Date of Birth'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(d.dateOfBirth.text) ?? DateTime(2010),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) d.dateOfBirth.text = picked.toIso8601String().split('T').first;
              },
            ),
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