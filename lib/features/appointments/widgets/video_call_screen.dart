import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/call_session_controller.dart';
import 'call_control_button.dart';
import 'participant_views.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // Purely visual, per-screen state. 
  final bool _isFullScreen = false;

  void _endCall(CallSessionController call) {
    call.end();
    Navigator.of(context).pop();
  }

  void _minimizeCall(CallSessionController call) {
    call.minimize();
    // This minimizes video and shows whatever screen the call was launched from 
    //The CallBubbleOverlay mounted at the app root takes over showing the floating bubble from here.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final call = context.watch<CallSessionController>();

    // Safety net: if this screen is ever shown without an active call
    // (e.g. after a hot restart), back out instead of crashing on a null appointment.
    if (!call.isActive || call.appointment == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
      return const SizedBox.shrink();
    }

    return PopScope(
      // The system/hardware back gesture always minimizes first and never directly ends the call.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _minimizeCall(call);
        }
      },
      child: Scaffold(
        backgroundColor: _isFullScreen ? Colors.black : Colors.white,
        appBar: _isFullScreen
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leadingWidth: 120,
                leading: TextButton.icon(
                  onPressed: () => _minimizeCall(call),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF5D53A3),
                  ),
                ),
              ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: _buildFullScreenMode(call)),
              if (_isFullScreen)
                Positioned(
                  top: 20,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => _minimizeCall(call),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 28,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CallControlButton(
                      icon: call.isMicOn ? Icons.mic : Icons.mic_off,
                      backgroundColor:
                          call.isMicOn ? Colors.white : const Color(0xFFFFEAEA),
                      iconColor:
                          call.isMicOn ? const Color(0xFF2F3E56) : Colors.red,
                      onTap: call.toggleMic,
                    ),
                    const SizedBox(width: 16),
                    CallControlButton(
                      icon: call.isCameraOn ? Icons.videocam : Icons.videocam_off,
                      backgroundColor: call.isCameraOn
                          ? Colors.white
                          : const Color(0xFFFFEAEA),
                      iconColor: call.isCameraOn
                          ? const Color(0xFF2F3E56)
                          : Colors.red,
                      onTap: call.toggleCamera,
                    ),
                    const SizedBox(width: 16),
                    CallControlButton(
                      icon: Icons.call_end,
                      backgroundColor: const Color(0xFFE53935),
                      iconColor: Colors.white,
                      // The ONLY control that actually ends the call.
                      onTap: () => _endCall(call),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenMode(CallSessionController call) {
    final primaryIsPatient = !call.isDoctorPrimary;

    return Stack(
      children: [
        Positioned.fill(
          child: FullScreenParticipantView(
            name: primaryIsPatient ? 'Patient' : 'Dr. Preview',
            roleTag: primaryIsPatient ? 'Patient' : 'Doctor',
            isPatient: primaryIsPatient,
          ),
        ),
        Positioned(
          top: 72,
          right: 14,
          child: GestureDetector(
            onTap: call.toggleDoctorPrimary,
            child: PipParticipantView(
              name: primaryIsPatient ? 'Dr. Preview' : 'Patient',
              isPatient: !primaryIsPatient,
            ),
          ),
        ),
      ],
    );
  }
}
