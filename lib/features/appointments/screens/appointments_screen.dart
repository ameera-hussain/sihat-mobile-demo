import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/check_in_button.dart';
import '../models/appointments_data.dart';
import '../providers/appointments_provider.dart';
import '../../../core/constants/app_decorations.dart';
import 'appointment_summary.dart';

enum _AppointmentFlowStep { choosePerson, chooseClinic, chooseSlot }

enum _ConsultationType { teleconsultation, physical, emergency, walkin }

class _Clinic {
  final String name;
  final String address;
  final String district;
  final String phone;

  const _Clinic({
    required this.name,
    required this.address,
    required this.district,
    required this.phone,
  });
}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  static const Color _accentColor = Color(0xFF5D53A3);

  final TextEditingController _clinicSearchController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final List<String> _familyMembers = const [
    'Haris Jamal',
    'Hannah Ghani',
    'Wan Rosli',
  ];
  final List<_Clinic> _clinics = const [
    _Clinic(
      name: 'Sihat Putrajaya Clinic',
      address: 'No. 12, Persiaran Perdana, Presint 4, Putrajaya',
      district: 'Putrajaya',
      phone: '+60 3-8899 1200',
    ),
    _Clinic(
      name: 'Sri Murni Family Clinic',
      address: '25, Jalan AU 2A/1, Keramat, Kuala Lumpur',
      district: 'Kuala Lumpur',
      phone: '+60 3-4257 8801',
    ),
    _Clinic(
      name: 'Sentral Care Medical Centre',
      address: 'Ground Floor, Jalan Tun Sambanthan, Brickfields',
      district: 'Brickfields',
      phone: '+60 3-2276 9912',
    ),
    _Clinic(
      name: 'Seri Damai Clinic',
      address: '11, Jalan Setiawangsa 13, Setiawangsa',
      district: 'Setiawangsa',
      phone: '+60 3-4251 7720',
    ),
  ];

  _AppointmentFlowStep _step = _AppointmentFlowStep.choosePerson;
  String? _selectedPerson;
  _Clinic? _selectedClinic;
  _ConsultationType? _selectedConsultationType;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedSlot;
  bool _slotsExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentsProvider>().fetchAppointments();
    });

    _clinicSearchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _clinicSearchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            if (_step != _AppointmentFlowStep.choosePerson)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _goToPreviousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
            const SizedBox(height: 24),
            _buildCurrentStep(context),
            const SizedBox(height: 12),
            if (_step == _AppointmentFlowStep.choosePerson) ...[
              const SizedBox(height: 16),
              if (provider.upcomingAppointments.isNotEmpty) ...[
                const Text(
                  'Upcoming Appointments',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...provider.upcomingAppointments.map(
                  (appointment) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildAppointmentCard(
                      context,
                      appointment,
                      isPast: false,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const Text(
                'Past Appointments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (provider.pastAppointments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No past appointments.'),
                ),
              ...provider.pastAppointments.map(
                (appointment) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAppointmentCard(
                    context,
                    appointment,
                    isPast: true,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _statusChip(AppointmentStatus status) {
    final (label, color) = switch (status) {
      AppointmentStatus.scheduled => ('Scheduled', const Color(0xFF2E7D32)),
      AppointmentStatus.cancelled => ('Cancelled', const Color(0xFFC62828)),
      AppointmentStatus.completed => ('Completed', const Color(0xFF1565C0)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    Appointment appointment, {
    required bool isPast,
  }) {
    final theme = Theme.of(context);
    final titleColor = isPast
        ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
        : theme.colorScheme.onSurface;
    final detailColor = isPast
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
        : theme.colorScheme.onSurfaceVariant;

    return Opacity(
      opacity: isPast ? 0.82 : 1,
      child: Container(
        decoration: cardDecoration.copyWith(
          color: isPast ? const Color(0xFFF3F3F7) : Colors.white,
          border: Border.all(
            color: isPast ? const Color(0xFFE2E2EA) : const Color(0xFFECE8FB),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/appointments/detail/${appointment.id}'),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateBadge(appointment, isPast: isPast),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.clinicName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _detailRow(
                          context,
                          icon: Icons.schedule_outlined,
                          text: _formatTime(appointment.date),
                          color: detailColor,
                        ),
                        const SizedBox(height: 4),
                        _detailRow(
                          context,
                          icon: _appointmentTypeIcon(appointment.type),
                          text: _appointmentTypeLabel(appointment.type),
                          color: detailColor,
                        ),
                        if (isPast) ...[
                          const SizedBox(height: 8),
                          _statusChip(appointment.status),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 28,
                      color: isPast
                          ? theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            )
                          : const Color(0xFF5D53A3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateBadge(Appointment appointment, {required bool isPast}) {
    final monthColor = isPast
        ? const Color(0xFF8A8A95)
        : appointment.iconAccent;
    final dayColor = isPast ? const Color(0xFF5F5F69) : appointment.iconAccent;

    return SizedBox(
      width: 70,
      height: 70,
      child: Container(
        decoration: BoxDecoration(
          color: isPast ? const Color(0xFFE7E7ED) : const Color(0xFF8DA6CA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _monthLabel(appointment.date),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: monthColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              appointment.date.day.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 25,
                height: 0.9,
                fontWeight: FontWeight.w700,
                color: dayColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_step) {
      case _AppointmentFlowStep.choosePerson:
        return _buildStepOne(context);
      case _AppointmentFlowStep.chooseClinic:
        return _buildStepTwo(context);
      case _AppointmentFlowStep.chooseSlot:
        return _buildStepThree(context);
    }
  }

  // SCREEN 1
  Widget _buildStepOne(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Book an Appointment for:',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ..._familyMembers.map(
          (member) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedPerson = member;
                  _step = _AppointmentFlowStep.chooseClinic;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: cardDecoration,
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        member,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        CheckInButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('QR scanning flow will open here.')),
            );
          },
        ),
      ],
    );
  }

  // SCREEN 2
  Widget _buildStepTwo(BuildContext context) {
    final query = _clinicSearchController.text.trim().toLowerCase();
    final filteredClinics = _clinics
        .where(
          (clinic) =>
              clinic.name.toLowerCase().contains(query) ||
              clinic.district.toLowerCase().contains(query),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select a Clinic',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _clinicSearchController,
                decoration: InputDecoration(
                  hintText: 'enter clinic name or district...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _accentColor.withValues(alpha: 0.35),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _accentColor.withValues(alpha: 0.35),
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide(color: _accentColor, width: 1.4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 52,
              width: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('GPS location lookup is not enabled yet.'),
                    ),
                  );
                },
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...filteredClinics.map(
          (clinic) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedClinic = clinic;
                  _step = _AppointmentFlowStep.chooseSlot;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: cardDecoration,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECE8FB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        size: 20,
                        color: Color(0xFF5D53A3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clinic.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            clinic.district,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (filteredClinics.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No clinics found for "$query"',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  // SCREEN 3
  Widget _buildStepThree(BuildContext context) {
    final clinic = _selectedClinic;
    if (clinic == null) {
      return const SizedBox.shrink();
    }

    final slots = _buildHalfHourSlots(_selectedDate);
    final visibleSlots = _slotsExpanded ? slots : slots.take(8).toList();
    final slotsRangeLabel = visibleSlots.isEmpty
        ? ''
        : '${_formatTime(visibleSlots.first)} - ${_formatTime(visibleSlots.last)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Appointment',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (_selectedPerson != null) ...[
          const SizedBox(height: 4),
          Text(
            'For: $_selectedPerson',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF5D53A3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clinic.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(clinic.address, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 4),
              Text('District: ${clinic.district}', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 4),
              Text('Phone: ${clinic.phone}', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Consultation Type',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _ConsultationTypeCard(
                    label: 'Teleconsultation',
                    icon: Icons.video_call_rounded,
                    isSelected:
                        _selectedConsultationType ==
                        _ConsultationType.teleconsultation,
                    onTap: () => setState(() {
                      _selectedConsultationType =
                          _ConsultationType.teleconsultation;
                    }),
                    accentColor: _accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ConsultationTypeCard(
                    label: 'Physical Visit',
                    icon: Icons.local_hospital_rounded,
                    isSelected:
                        _selectedConsultationType == _ConsultationType.physical,
                    onTap: () => setState(() {
                      _selectedConsultationType = _ConsultationType.physical;
                    }),
                    accentColor: _accentColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ConsultationTypeCard(
                    label: 'Emergency',
                    icon: Icons.emergency,
                    isSelected:
                        _selectedConsultationType ==
                        _ConsultationType.emergency,
                    onTap: () => setState(() {
                      _selectedConsultationType = _ConsultationType.emergency;
                    }),
                    accentColor: _accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ConsultationTypeCard(
                    label: 'Walk-in',
                    icon: Icons.directions_walk,
                    isSelected:
                        _selectedConsultationType == _ConsultationType.walkin,
                    onTap: () => setState(() {
                      _selectedConsultationType = _ConsultationType.walkin;
                    }),
                    accentColor: _accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Reason',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _reasonController,
          maxLines: 3,
          minLines: 3,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Briefly describe the reason for this appointment...',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _accentColor.withValues(alpha: 0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _accentColor.withValues(alpha: 0.35),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(color: _accentColor, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildDateSelector(context),
        const SizedBox(height: 15),
        Row(
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Available Slots ($slotsRangeLabel)',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final slotWidth = (constraints.maxWidth - (spacing * 2)) / 3;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: visibleSlots.map((slot) {
                final isSelected =
                    _selectedSlot != null &&
                    _selectedSlot!.isAtSameMomentAs(slot);
                final slotDateTime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  slot.hour,
                  slot.minute,
                );
                final isUnavailable = !slotDateTime.isAfter(DateTime.now());

                final bgColor = isSelected
                    ? _accentColor
                    : isUnavailable
                    ? const Color(0xFFF1EFF9)
                    : Colors.white;
                final borderColor = isSelected
                    ? _accentColor
                    : isUnavailable
                    ? const Color(0xFFE3DEEF)
                    : _accentColor.withValues(alpha: 0.35);
                final textColor = isSelected
                    ? Colors.white
                    : isUnavailable
                    ? Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.onSurface;

                return SizedBox(
                  width: slotWidth,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: isUnavailable
                        ? null
                        : () {
                            setState(() {
                              _selectedSlot = slot;
                            });
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: borderColor),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _accentColor.withValues(alpha: 0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : const [],
                      ),
                      child: Text(
                        _formatTime(slot),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        if (!_slotsExpanded && slots.length > 8) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() {
                _slotsExpanded = true;
              }),
              style: TextButton.styleFrom(foregroundColor: _accentColor),
              child: const Text('See more time slots'),
            ),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed:
                _selectedSlot == null ||
                    _selectedConsultationType == null ||
                    _reasonController.text.trim().isEmpty
                ? null
                : () async {
                    final slot = _selectedSlot!;
                    final selectedDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      slot.hour,
                      slot.minute,
                    );

                    final summary = AppointmentBookingSummaryData(
                      clinicName: clinic.name,
                      clinicAddress:
                          '${clinic.address}, ${clinic.district}, ${clinic.phone}',
                      patientName: _selectedPerson ?? 'Unknown Patient',
                      type: AppointmentType
                          .values[_selectedConsultationType!.index],
                      reason: _reasonController.text.trim(),
                      appointmentDateTime: selectedDateTime,
                    );

                    final wasConfirmed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) =>
                            AppointmentBookingSummaryScreen(summary: summary),
                      ),
                    );

                    if (!context.mounted || wasConfirmed != true) {
                      return;
                    }

                    final provider = context.read<AppointmentsProvider>();
                    final added = await provider
                        .addAppointmentFromBookingSummary(summary);
                    if (!context.mounted) {
                      return;
                    }
                    if (!added) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to confirm appointment.'),
                        ),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment confirmed successfully.'),
                      ),
                    );

                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _step = _AppointmentFlowStep.choosePerson;
                      _selectedPerson = null;
                      _selectedClinic = null;
                      _selectedConsultationType = null;
                      _selectedSlot = null;
                      _slotsExpanded = false;
                      _clinicSearchController.clear();
                      _reasonController.clear();
                      _selectedDate = DateTime.now().add(
                        const Duration(days: 1),
                      );
                    });
                  },
            child: const Text(
              'Confirm Appointment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final borderColor = const Color(0xFFD4D7E2);
    final iconColor = _accentColor.withValues(alpha: 0.95);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final now = DateTime.now();
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: now,
            lastDate: now.add(const Duration(days: 90)),
          );

          if (pickedDate != null) {
            setState(() {
              _selectedDate = pickedDate;
              _selectedSlot = null;
            });
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 19,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF17171F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 30,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToPreviousStep() {
    setState(() {
      if (_step == _AppointmentFlowStep.chooseSlot) {
        _step = _AppointmentFlowStep.chooseClinic;
        _selectedConsultationType = null;
        _selectedSlot = null;
        _slotsExpanded = false;
        _reasonController.clear();
      } else if (_step == _AppointmentFlowStep.chooseClinic) {
        _step = _AppointmentFlowStep.choosePerson;
      }
    });
  }

  IconData _appointmentTypeIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.teleconsultation:
        return Icons.video_call_rounded;
      case AppointmentType.physical:
        return Icons.local_hospital_rounded;
      case AppointmentType.emergency:
        return Icons.emergency;
      case AppointmentType.walkin:
        return Icons.directions_walk;
    }
  }

  List<DateTime> _buildHalfHourSlots(DateTime date) {
    final start = DateTime(date.year, date.month, date.day, 8, 30);
    final end = DateTime(date.year, date.month, date.day, 21, 0);
    final slots = <DateTime>[];

    var slot = start;
    while (!slot.isAfter(end)) {
      slots.add(slot);
      slot = slot.add(const Duration(minutes: 30));
    }

    return slots;
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _monthLabel(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[date.month - 1];
  }

  String _appointmentTypeLabel(AppointmentType type) {
    switch (type) {
      case AppointmentType.teleconsultation:
        return 'Teleconsultation';
      case AppointmentType.physical:
        return 'Physical Visit';
      case AppointmentType.emergency:
        return 'Emergency';
      case AppointmentType.walkin:
        return 'Walk-in';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

class _ConsultationTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color accentColor;

  const _ConsultationTypeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: cardDecoration.copyWith(
          color: isSelected ? accentColor : Color(0XFF5D53A3).withValues(alpha: 0.08),
          border: Border.all(
            color: isSelected
                ? accentColor
                : accentColor.withValues(alpha: 0.25),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 36,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
