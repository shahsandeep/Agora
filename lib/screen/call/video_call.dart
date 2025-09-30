import 'dart:async';
import 'package:agora_call/models/agora_model.dart';
import 'package:agora_call/services/firebase_service.dart';
import 'package:agora_call/utils/const/const.dart';
import 'package:agora_call/utils/helper/helper.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CallStatus {
  calling('ringing'),
  connected('connected'),
  disconnected('disconnected'),
  noAnswer('no_answer');

  final String value;
  const CallStatus(this.value);
}

class AgoraVideoCall extends StatefulWidget {
  final bool isCaller;
  final AgoraCallParamsModel params;
  const AgoraVideoCall({required this.isCaller, required this.params, super.key});

  @override
  State<AgoraVideoCall> createState() => _AgoraVideoCallState();
}

class _AgoraVideoCallState extends State<AgoraVideoCall> {
  AgoraClient? client;
  Timer? timer;
  final FirebaseRepo callProvider = FirebaseRepo();

  bool isCaller = true;
  String currentUserId = "1";
  String callerName = "Caller";
  String receiverName = '';
  String? channelName = '';
  String callType = 'video';
  bool _isCallDisconnected = false;
  String peerName = '';
  bool isScreenSharing = false;
  bool isProcessing = false;

  static const int kScreenShareUid = 10000;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  void _initAgora() async {
    receiverName = widget.params.receiverName ?? "";
    peerName = receiverName;

    if (widget.params.callerId != currentUserId && widget.params.callerId != null) {
      isCaller = false;
      callerName = widget.params.callerName ?? "";
      receiverName = "Caller";
      peerName = callerName;
    }

    String callStatus = 'connected';

    channelName = widget.params.channelName;
    if (channelName == null) {
      channelName = "agoratest";
      callStatus = 'ringing';
    }

    FirebaseRepo().createOrUpdateCallDocument(
      callerId: currentUserId,
      callerName: callerName,
      receiverName: receiverName,
      channelId: channelName ?? "",
      receiverId: widget.params.receiverId ?? "",
      status: callStatus,
      callType: callType,
    );

    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: AgoraConstants.appId,
        screenSharingEnabled: true,
        tempToken: widget.params.tempToken ?? AgoraConstants.token,
        channelName: channelName ?? '',
        username: 'Caller',
        screenSharingUid: kScreenShareUid,
      ),
      enabledPermission: const [
        Permission.camera,
        Permission.microphone,
      ],
    );

    await client?.initialize();

    if (client?.isInitialized ?? false) {
      final engine = client!.engine;

      await engine.enableVideo();
      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await engine.setEnableSpeakerphone(true);

      await engine.updateChannelMediaOptions(
        const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          publishScreenCaptureVideo: false,
          publishScreenCaptureAudio: false,
        ),
      );

      client?.sessionController.addListener(() {
        final shared = client?.sessionController.value.isScreenShared ?? false;
        if (mounted) {
          setState(() {
            isScreenSharing = shared;
          });
        }
        print('screen share changed: $shared');
      });
    }
  }

  Future<void> shareScreen() async {
    if (client == null || isProcessing) return;

    setState(() => isProcessing = true);

    try {
      final engine = client!.engine;

      await engine.updateChannelMediaOptions(
        const ChannelMediaOptions(
          publishCameraTrack: false,
          publishMicrophoneTrack: true,
          publishScreenCaptureVideo: true,
          publishScreenCaptureAudio: true,
        ),
      );

      await engine.startScreenCapture(
        const ScreenCaptureParameters2(
          captureAudio: true,
          captureVideo: true,
          audioParams: ScreenAudioParameters(
            sampleRate: 48000,
            channels: 2,
            captureSignalVolume: 100,
          ),
          videoParams: ScreenVideoParameters(
            dimensions: VideoDimensions(width: 1280, height: 720),
            frameRate: 15,
            bitrate: 2000,
          ),
        ),
      );

      setState(() {
        isScreenSharing = true;
      });

      Helpers.showToast("Screen sharing started");

    } catch (e) {

      Helpers.showToast("Failed to start screen sharing");
      setState(() {
        isScreenSharing = false;
      });
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> stopShareScreen() async {
    if (client == null || isProcessing) return;

    setState(() => isProcessing = true);

    try {
      final engine = client!.engine;

      await engine.stopScreenCapture();

      await engine.updateChannelMediaOptions(
        const ChannelMediaOptions(
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          publishScreenCaptureVideo: false,
          publishScreenCaptureAudio: false,
        ),
      );

      setState(() {
        isScreenSharing = false;
      });

      Helpers.showToast("Screen sharing stopped");

    } catch (e) {
   
      Helpers.showToast("Failed to stop screen sharing");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: callProvider.videoCallStream(isCaller: isCaller, channelName: channelName),
          builder: (ctx, snapshot) {
            String status = 'ringing';
            if (snapshot.hasData) {
              if (snapshot.data!.docs.isNotEmpty) {
                status = snapshot.data!.docs.first.data()['status'];
                if (status == 'disconnected') {
                  if (mounted && !_isCallDisconnected) {
                    _isCallDisconnected = true;
                    Navigator.pop(context);
                  }
                }
              }
            }
            return SafeArea(
              child: client != null
                  ? Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              AgoraVideoViewer(
                                client: client!,
                                layoutType: Layout.grid,
                                showNumberOfUsers: true,
                                renderModeType: RenderModeType.renderModeAdaptive,
                              ),
                              if (isScreenSharing)
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.screen_share, color: Colors.white, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          'Sharing Screen',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: AgoraVideoButtons(
                                  addScreenSharing: false,
                                  client: client!,
                                  extraButtons: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: isProcessing
                                              ? null
                                              : (isScreenSharing ? stopShareScreen : shareScreen),
                                          icon: Icon(
                                            isScreenSharing
                                                ? Icons.stop_screen_share
                                                : Icons.screen_share,
                                          ),
                                          color: isScreenSharing ? Colors.red : Colors.white,
                                          tooltip: isScreenSharing ? 'Stop sharing' : 'Share screen',
                                          iconSize: 28,
                                        ),
                                        if (isProcessing)
                                          const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                  onDisconnect: () async {
                                    _isCallDisconnected = true;

                                    if (isScreenSharing) {
                                      await stopShareScreen();
                                    }

                                    FirebaseRepo().createOrUpdateCallDocument(
                                      callerId: currentUserId,
                                      receiverName: receiverName,
                                      callerName: callerName,
                                      channelId: channelName ?? '',
                                      receiverId: widget.params.receiverId ?? "",
                                      status: 'disconnected',
                                      callType: callType,
                                    );

                                    if (mounted) {
                                      Navigator.pop(context);
                                    }
                                    Helpers.showToast("Call Disconnected");
                                  },
                                ),
                              ),
                              if (status == 'ringing')
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Card(
                                    color: Colors.black.withOpacity(0.5),
                                    child: const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(
                                        'Connecting...',
                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (isScreenSharing) {
      stopShareScreen();
    }
    client?.release();
    timer?.cancel();
    super.dispose();
  }
}
