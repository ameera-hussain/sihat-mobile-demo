import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/my_profile_data.dart';
import '../providers/allergies_provider.dart';
import 'section_header.dart';
import 'labeled_value.dart';

class AllergiesSection extends StatefulWidget {
  final List<MyAllergies> entries;
  const AllergiesSection({super.key, required this.entries});

  @override
  State<AllergiesSection> createState() => _AllergiesSectionState();
}

class _EntryControllers {
  final TextEditingController allergen;
  final TextEditingController reaction;
  final TextEditingController notes;
  String id;

  _EntryControllers(MyAllergies e)
      : id = e.id,
        allergen = TextEditingController(text: e.allergen),
        reaction = TextEditingController(text: e.reaction),
        notes = TextEditingController(text: e.notes);

  MyAllergies toModel() => MyAllergies(
        id: id,
        allergen: allergen.text,
        reaction: reaction.text,
        notes: notes.text,
      );

  void dispose() {
    allergen.dispose();
    reaction.dispose();
    notes.dispose();
  }
}

class _AllergiesSectionState extends State<AllergiesSection> {
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
          MyAllergies(id: DateTime.now().microsecondsSinceEpoch.toString()),
        ));
      });

  void _removeRow(int index) => setState(() => _drafts.removeAt(index));

  Future<void> _saveEdit() async {
    setState(() => _isSaving = true);
    final updated = _drafts.map((d) => d.toModel()).toList();
    await context.read<AllergiesProvider>().saveAll(updated);
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
          title: 'Allergies',
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
                      label: const Text('Add allergy'),
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
      return [Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Text('No allergies recorded.'))];
    }
    return widget.entries.asMap().entries.map((entry) {
      final idx = entry.key;
      final e = entry.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LabeledValue(label: 'Allergen', value: e.allergen),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LabeledValue(label: 'Reaction', value: e.reaction),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LabeledValue(label: 'Severity', value: e.severity),
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
                Expanded(child: TextFormField(controller: d.allergen, decoration: const InputDecoration(labelText: 'Allergen'))),
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
              controller: d.reaction,
              decoration: const InputDecoration(labelText: 'Reaction'),
            ),
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