import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/my_profile_data.dart';
import '../providers/profile_provider.dart';
import 'section_header.dart';
import 'labeled_value.dart';

class PersonalInfoSection extends StatefulWidget {
  final MyProfileData profile;
  const PersonalInfoSection({super.key, required this.profile});

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _nationalityController;
  late TextEditingController _phoneController;
  late TextEditingController _idNumberController;
  late TextEditingController _dobController;
  late TextEditingController _ethnicityController;
  late TextEditingController _addressController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  late TextEditingController _postcodeController;
  late TextEditingController _stateController;

  IdentificationType? _identificationType;
  GenderType? _genderType;

  @override
  void initState() {
    super.initState();
    _initControllers(widget.profile);
  }

  void _initControllers(MyProfileData p) {
    _nameController = TextEditingController(text: p.name);
    _emailController = TextEditingController(text: p.email);
    _nationalityController = TextEditingController(text: p.nationality);
    _phoneController = TextEditingController(text: p.phoneNumber);
    _idNumberController = TextEditingController(text: p.identificationnumber);
    _dobController = TextEditingController(text: p.dateOfBirth);
    _ethnicityController = TextEditingController(text: p.ethnicity);
    _addressController = TextEditingController(text: p.address);
    _districtController = TextEditingController(text: p.district);
    _cityController = TextEditingController(text: p.city);
    _postcodeController = TextEditingController(text: p.postcode);
    _stateController = TextEditingController(text: p.state);
    _identificationType = p.identificationType;
    _genderType = p.genderType;
  }

  @override
  void didUpdateWidget(covariant PersonalInfoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && oldWidget.profile != widget.profile) {
      _initControllers(widget.profile);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameController, _emailController, _nationalityController, _phoneController,
      _idNumberController, _dobController, _ethnicityController, _addressController,
      _districtController, _cityController, _postcodeController, _stateController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _cancelEdit() => setState(() {
        _initControllers(widget.profile);
        _isEditing = false;
      });

  Future<void> _saveEdit() async {
    setState(() => _isSaving = true);

    final updated = MyProfileData(
      id: widget.profile.id,
      name: _nameController.text,
      email: _emailController.text,
      nationality: _nationalityController.text,
      phoneNumber: _phoneController.text,
      identificationType: _identificationType,
      identificationnumber: _idNumberController.text,
      dateOfBirth: _dobController.text,
      genderType: _genderType,
      ethnicity: _ethnicityController.text,
      address: _addressController.text,
      district: _districtController.text,
      city: _cityController.text,
      postcode: _postcodeController.text,
      state: _stateController.text,
    );

    await context.read<ProfileProvider>().updateProfileData(updated);

    if (mounted) setState(() { _isSaving = false; _isEditing = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Personal Information',
          isEditing: _isEditing,
          onEditPressed: () => setState(() => _isEditing = true),
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isSaving)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: LinearProgressIndicator(),
                  ),
                if (!_isEditing) _buildView() else _buildEdit(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildView() {
    final p = widget.profile;
    final items = [
      ('Name', p.name),
      ('Email', p.email),
      ('Nationality', p.nationality),
      ('Phone', p.phoneNumber),
      ('ID Type', p.identificationType?.name),
      ('ID Number', p.identificationnumber),
      ('Date of Birth', p.dateOfBirth),
      ('Gender', p.genderType?.name),
      ('Ethnicity', p.ethnicity),
      ('Address', p.address),
      ('District', p.district),
      ('City', p.city),
      ('Postcode', p.postcode),
      ('State', p.state),
    ];
    
    return Column(
      children: List.generate(items.length, (i) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: LabeledValue(label: items[i].$1, value: items[i].$2),
            ),
            if (i < items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(height: 1, color: Colors.grey.shade200),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildEdit() {
    final fields = [
      ('Name', _nameController, TextInputType.text, null),
      ('Email', _emailController, TextInputType.emailAddress, null),
      ('Nationality', _nationalityController, TextInputType.text, null),
      ('Phone Number', _phoneController, TextInputType.phone, null),
      ('Identification Number', _idNumberController, TextInputType.text, null),
      ('Ethnicity', _ethnicityController, TextInputType.text, null),
      ('Address', _addressController, TextInputType.text, null),
      ('District', _districtController, TextInputType.text, null),
      ('City', _cityController, TextInputType.text, null),
      ('Postcode', _postcodeController, TextInputType.text, null),
      ('State', _stateController, TextInputType.text, null),
    ];

    return Column(
      children: [
        ...List.generate(fields.length, (i) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextFormField(
                  controller: fields[i].$2,
                  decoration: InputDecoration(labelText: fields[i].$1),
                  keyboardType: fields[i].$3,
                ),
              ),
              if (i < fields.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: Colors.grey.shade200),
                ),
            ],
          );
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: DropdownButtonFormField<IdentificationType>(
            initialValue: _identificationType,
            decoration: const InputDecoration(labelText: 'Identification Type'),
            items: IdentificationType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
            onChanged: (v) => setState(() => _identificationType = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: const InputDecoration(labelText: 'Date of Birth'),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(_dobController.text) ?? DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) _dobController.text = picked.toIso8601String().split('T').first;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: DropdownButtonFormField<GenderType>(
            initialValue: _genderType,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: GenderType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
            onChanged: (v) => setState(() => _genderType = v),
          ),
        ),
      ],
    );
  }
}