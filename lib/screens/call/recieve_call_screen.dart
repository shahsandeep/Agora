import 'package:agora_call/services/firebase_service.dart';
import 'package:agora_call/screens/call/audio_call.dart';
import 'package:agora_call/screens/call/video_call.dart';
import 'package:agora_call/utils/const/const.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/agora_model.dart';
import '../../services/local_notification.dart';
import '../../utils/helper/helper.dart';

class RecieveCallScreen extends StatefulWidget {
  const RecieveCallScreen({super.key});

  @override
  State<RecieveCallScreen> createState() => _RecieveCallScreenState();
}

OverlayEntry? _overlayEntry;

class _RecieveCallScreenState extends State<RecieveCallScreen>
    with WidgetsBindingObserver {
  final player = AudioPlayer();
  QueryDocumentSnapshot<Map<String, dynamic>>? _currentCallSnapshot;
  bool _isProcessingCall = false;
  String? _lastProcessedCallId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app comes to foreground and there's a pending call, show overlay
    if (state == AppLifecycleState.resumed && _currentCallSnapshot != null) {
      final status = _currentCallSnapshot?.data()['status'];
      if (status == 'ringing' && _overlayEntry == null) {
        _showCallUI(_currentCallSnapshot!);
      }
    }
  }

  Future<void> _initializeNotifications() async {
    await CallNotificationService().init(
      onAction: (action) {
        if (_currentCallSnapshot == null) {
          return;
        }

        if (action == 'ACCEPT') {
          _acceptCall(_currentCallSnapshot!);
        } else if (action == 'REJECT') {
          _rejectCall(_currentCallSnapshot!);
        }
      },
    );

    // Check if notifications are enabled
    final enabled = await CallNotificationService().areNotificationsEnabled();
    if (!enabled && mounted) {
      _showEnableNotificationsDialog();
    }
  }

  void _showEnableNotificationsDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Notifications'),
          content: const Text(
            'Please enable notifications to receive incoming calls when the app is in background.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Enable'),
            ),
          ],
        ),
      );
    });
  }

  void _showCallUI(QueryDocumentSnapshot<Map<String, dynamic>> callSnapshot) {
    final String callerName = callSnapshot.data()['callerName'] ?? 'Unknown';
    final String callType = callSnapshot.data()['callType'] ?? 'Voice';
    final String callId = callSnapshot.id;

    if (_lastProcessedCallId == callId && _overlayEntry != null) {
      return;
    }

    _lastProcessedCallId = callId;

    _showOverlay(
      onCallPickup: () => _acceptCall(callSnapshot),
      onCallEnd: () => _rejectCall(callSnapshot),
      userName: callerName,
      callType: callType,
    );

    CallNotificationService().showIncomingCallNotification(
      callerName: callerName,
      callType: callType,
    );
  }

  Future<void> _showOverlay({
    required Function() onCallPickup,
    required Function() onCallEnd,
    required String userName,
    required String callType,
  }) async {
    if (_overlayEntry != null) return;

    try {
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource('mp3/ring_audio.mp3'));
    } catch (e) {}

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black87,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade900,
                  Colors.purple.shade900,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          callType.toLowerCase() == 'video'
                              ? Icons.videocam
                              : Icons.phone,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Incoming ${callType.toUpperCase()} Call',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60.0),
                  const _RingingAnimation(),
                  const SizedBox(height: 60.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Reject Button
                        Column(
                          children: [
                            GestureDetector(
                              onTap: onCallEnd,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Decline',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        Column(
                          children: [
                            GestureDetector(
                              onTap: onCallPickup,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  callType.toLowerCase() == 'video'
                                      ? Icons.videocam
                                      : Icons.call,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Accept',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    AgoraConstants.navigatorKey.currentState?.overlay?.insert(_overlayEntry!);
  }

  void removeOverlay() {
    try {
      player.stop();
    } catch (e) {}

    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _acceptCall(QueryDocumentSnapshot<Map<String, dynamic>> ringSnapshot) {
    if (_isProcessingCall) return;
    _isProcessingCall = true;

    final String? callerId = ringSnapshot.data()['callerId'];
    final String? callerName = ringSnapshot.data()['callerName'];
    final String? channelId = ringSnapshot.data()['channelName'];
    final String? receiverId = ringSnapshot.data()['receiverId'];
    final String? callType = ringSnapshot.data()['callType'];

    removeOverlay();
    CallNotificationService().cancelNotification();
    _currentCallSnapshot = null;
    _lastProcessedCallId = null;

    if (!mounted) return;

    if (callType?.toLowerCase() == 'voice') {
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => AgoraAudioCall(
            params: AgoraCallParamsModel(
              callerId: callerId ?? '',
              callerName: callerName ?? '',
              channelName: channelId ?? '',
              receiverId: receiverId ?? '',
              tempToken: AgoraConstants.token,
            ),
            isCaller: false,
          ),
        ),
      )
          .then((_) {
        _isProcessingCall = false;
      });
    } else {
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (context) => AgoraVideoCall(
            params: AgoraCallParamsModel(
              callerId: callerId ?? '',
              callerName: callerName ?? '',
              channelName: channelId ?? '',
              receiverId: receiverId ?? '',
              tempToken: AgoraConstants.token,
            ),
            isCaller: false,
          ),
        ),
      )
          .then((_) {
        _isProcessingCall = false;
      });
    }
  }

  Future<void> _rejectCall(
      QueryDocumentSnapshot<Map<String, dynamic>> ringSnapshot) async {
    if (_isProcessingCall) return;
    _isProcessingCall = true;

    final String? callerId = ringSnapshot.data()['callerId'];
    final String? channelId = ringSnapshot.data()['channelName'];
    final String? receiverId = ringSnapshot.data()['receiverId'];
    final String? callType = ringSnapshot.data()['callType'];
    final String? callerName = ringSnapshot.data()['callerName'];
    final String? receiverName = ringSnapshot.data()['receiverName'];

    try {
      await FirebaseRepo().createOrUpdateCallDocument(
        callerId: callerId ?? "",
        callerName: callerName ?? '',
        receiverName: receiverName ?? '',
        channelId: channelId ?? '',
        receiverId: receiverId ?? '',
        status: 'disconnected',
        callType: callType ?? '',
      );

      removeOverlay();
      CallNotificationService().cancelNotification();
      _currentCallSnapshot = null;
      _lastProcessedCallId = null;

      Helpers.showToast("Call Rejected");
    } catch (e) {
      Helpers.showToast("Failed to reject call");
    } finally {
      _isProcessingCall = false;
    }
  }

  void _handleCall(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
    String? currentUserId,
  ) {
    if (snapshot.data?.docs.isEmpty ?? true) {
      // No calls, clean up if needed
      if (_overlayEntry != null) {
        removeOverlay();
        CallNotificationService().cancelNotification();
        _currentCallSnapshot = null;
        _lastProcessedCallId = null;
      }
      return;
    }

    QueryDocumentSnapshot<Map<String, dynamic>>? ringSnapshot;

    for (var doc in snapshot.data!.docs) {
      final data = doc.data();
      if (data['status'] == 'ringing' && data['receiverId'] == currentUserId) {
        ringSnapshot = doc;
        break;
      }
    }

    if (ringSnapshot != null) {
      final String? status = ringSnapshot.data()['status'];
      final String? receiverId = ringSnapshot.data()['receiverId'];

      if (status == 'ringing' && receiverId == currentUserId) {
        _currentCallSnapshot = ringSnapshot;

        _showCallUI(ringSnapshot);
      }
    } else {
      if (_overlayEntry != null) {
        if (player.state == PlayerState.playing) {
          Helpers.showToast("Call Disconnected");
        }
        removeOverlay();
        CallNotificationService().cancelNotification();
        _currentCallSnapshot = null;
        _lastProcessedCallId = null;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    removeOverlay();
    player.dispose();
    CallNotificationService().cancelNotification();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseRepo().videoCallStream(
        isCaller: false,
        isFromMain: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data?.docs.isNotEmpty ?? false) {
            _handleCall(snapshot, '2');
          } else {
            if (_overlayEntry != null) {
              removeOverlay();
              CallNotificationService().cancelNotification();
              _currentCallSnapshot = null;
              _lastProcessedCallId = null;
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Receive Call Screen'),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_in_talk,
                  size: 80,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Waiting for incoming calls...',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You will be notified when someone calls',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RingingAnimation extends StatefulWidget {
  const _RingingAnimation();

  @override
  State<_RingingAnimation> createState() => _RingingAnimationState();
}

class _RingingAnimationState extends State<_RingingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildRipple(0.0),
        _buildRipple(0.33),
        _buildRipple(0.66),
      ],
    );
  }

  Widget _buildRipple(double delay) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, 1.0, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 80 + (animation.value * 80),
          height: 80 + (animation.value * 80),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(1.0 - animation.value),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}
