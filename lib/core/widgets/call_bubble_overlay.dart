import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/call_session_controller.dart';
import '../../features/appointments/widgets/participant_views.dart';
import '../../features/appointments/widgets/video_call_screen.dart';

/// Mount this ONCE near the root of the app (see MaterialApp.builder in
/// main.dart) so the floating call bubble can appear over *any* screen,
/// independent of whatever route the Navigator currently has on top.
class CallBubbleOverlay extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const CallBubbleOverlay({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<CallBubbleOverlay> createState() => _CallBubbleOverlayState();
}

class _CallBubbleOverlayState extends State<CallBubbleOverlay> {
  static const double _bubbleWidth = 120;
  static const double _bubbleHeight = 168;
  static const double _bubbleMargin = 16;

  Offset? _bubbleOffset;
  double _dragDistance = 0;

  Offset _clampBubbleOffset(Offset offset, Size screenSize) {
    final maxX = (screenSize.width - _bubbleWidth - _bubbleMargin)
        .clamp(_bubbleMargin, double.infinity);
    final maxY = (screenSize.height - _bubbleHeight - _bubbleMargin)
        .clamp(_bubbleMargin, double.infinity);
    return Offset(
      offset.dx.clamp(_bubbleMargin, maxX),
      offset.dy.clamp(_bubbleMargin, maxY),
    );
  }

  void _snapBubbleToEdge(Size screenSize) {
    if (_bubbleOffset == null) return;
    final centerX = _bubbleOffset!.dx + _bubbleWidth / 2;
    final isLeftHalf = centerX < screenSize.width / 2;
    final targetX = isLeftHalf
        ? _bubbleMargin
        : screenSize.width - _bubbleWidth - _bubbleMargin;
    setState(() => _bubbleOffset = Offset(targetX, _bubbleOffset!.dy));
  }

  String _formatElapsed(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _restore(CallSessionController call) {
    call.restore();
    widget.navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const VideoCallScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final call = context.watch<CallSessionController>();
    final screenSize = MediaQuery.of(context).size;
    final showBubble = call.isActive && call.isMinimized;

    if (showBubble) {
      _bubbleOffset ??= Offset(
        screenSize.width - _bubbleWidth - _bubbleMargin,
        screenSize.height - _bubbleHeight - 140,
      );
    }

    return Stack(
      children: [
        widget.child,
        if (showBubble)
          Positioned(
            left: _bubbleOffset!.dx,
            top: _bubbleOffset!.dy,
            child: GestureDetector(
              onPanStart: (_) => _dragDistance = 0,
              onPanUpdate: (details) {
                setState(() {
                  _dragDistance += details.delta.distance;
                  _bubbleOffset = _clampBubbleOffset(
                    _bubbleOffset! + details.delta,
                    screenSize,
                  );
                });
              },
              onPanEnd: (_) {
                // Small movement = tap → restore. Larger = drag → snap
                // to the nearest edge.
                if (_dragDistance < 6) {
                  _restore(call);
                } else {
                  _snapBubbleToEdge(screenSize);
                }
              },
              child: Container(
                width: _bubbleWidth,
                height: _bubbleHeight,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.25 * 255).toInt()),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PipParticipantView(
                      name: call.isDoctorPrimary ? 'Dr. Preview' : 'Patient',
                      isPatient: !call.isDoctorPrimary,
                    ),
                    Positioned(
                      left: 6,
                      right: 6,
                      bottom: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _formatElapsed(call.elapsed),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (!call.isMicOn)
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mic_off,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
