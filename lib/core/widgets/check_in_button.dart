import 'package:flutter/material.dart';

class CheckInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CheckInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 520;
            final content = isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _CheckInCopy(),
                      const SizedBox(height: 16),
                      _CheckInActionButton(onPressed: onPressed),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(child: _CheckInCopy()),
                      const SizedBox(width: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: _CheckInActionButton(onPressed: onPressed),
                      ),
                    ],
                  );

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF5D53A3),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: isCompact ? 20 : 35,
              ),
              child: content,
            );
          },
        ),
      ],
    );
  }
}

class _CheckInCopy extends StatelessWidget {
  const _CheckInCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Walk-in',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Arrived at the Clinic?',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }
}

class _CheckInActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CheckInActionButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE96DAA),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text(
          'Check in with QR code',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
