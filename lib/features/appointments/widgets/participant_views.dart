import 'package:flutter/material.dart';

class FullScreenParticipantView extends StatelessWidget {
  final String name;
  final String roleTag;
  final bool isPatient;

  const FullScreenParticipantView({super.key, 
    required this.name,
    required this.roleTag,
    required this.isPatient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isPatient
              ? [const Color(0xFF8A6A35), const Color(0xFF1E1A16)]
              : [const Color(0xFF2E3E5C), const Color(0xFF111827)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPatient
                        ? Icons.person_outline
                        : Icons.medical_services_outlined,
                    size: 66,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 14,
            bottom: 112,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
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

class PipParticipantView extends StatelessWidget {
  final String name;
  final bool isPatient;

  const PipParticipantView({super.key, required this.name, required this.isPatient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 106,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isPatient
              ? [const Color(0xFF846634), const Color(0xFF2C241D)]
              : [const Color(0xFF2E3C5D), const Color(0xFF121C31)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              isPatient ? Icons.person_outline : Icons.medical_services_outlined,
              color: Colors.white,
              size: 34,
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Text(
              '$name (tap to swap)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
