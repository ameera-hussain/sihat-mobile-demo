import 'package:flutter/material.dart';

class ParticipantTile extends StatelessWidget {
  final String name;
  final String subLabel;
  final String roleTag;
  final bool isPatient;

  const ParticipantTile({super.key, 
    required this.name,
    required this.subLabel,
    required this.roleTag,
    required this.isPatient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isPatient ? const Color(0xFF0D1635) : const Color(0xFF202D49),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: isPatient
                        ? const Color(0xFF334769)
                        : const Color(0xFF5F54BD),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPatient ? Icons.person_outline : Icons.medical_services_outlined,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                roleTag,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
