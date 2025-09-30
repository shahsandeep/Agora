import 'dart:async';

import 'package:agora_call/models/agora_model.dart';
import 'package:agora_call/utils/const/const.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/firebase_service.dart';
import '../../utils/helper/helper.dart';

class AgoraAudioCall extends StatefulWidget {
  final bool isCaller;
  final AgoraCallParamsModel params;

  const AgoraAudioCall(
      {required this.params, required this.isCaller, super.key});

  @override
  State<AgoraAudioCall> createState() => _AgoraAudioCallState();
}

class _AgoraAudioCallState extends State<AgoraAudioCall> {
  String token = "";
  int uid = 0;
  int? _remoteUid;
  bool _isJoined = false;
  RtcEngine? agoraEngine;
  ValueNotifier<String> remainingTime = ValueNotifier("");
  ValueNotifier<bool> micOn = ValueNotifier(true);
  ValueNotifier<bool> speakerOn = ValueNotifier(false);
  Timer? timer;

  int timeInSec = 0;

  ValueNotifier<String> notifyText = ValueNotifier("Connecting");

  final FirebaseRepo callProvider = FirebaseRepo();
  String callType = 'voice';

  bool isCaller = true;
  String currentUserId = "1";
  String callerName = "Caller";
  String receiverName = '';
  String? channelName = '';
  String? peerName = '';
  bool _isCallDisconnected = false;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(); // Global key to access the scaffold

  showMessage(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  void _initAgora() async {
    token = widget.params.tempToken ?? AgoraConstants.token;

    receiverName = widget.params.receiverName ?? "";
    peerName = isCaller? receiverName : "Caller";

    if (widget.params.callerId != currentUserId &&
        widget.params.callerId != null) {
      isCaller = false;
      callerName = widget.isCaller? widget.params.callerName ?? '' :'Reciever' ?? "";
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
        callType: callType);

    await _setupVoiceSDKEngine();
    await _join();
  }

  Future<void> _setupVoiceSDKEngine() async {
    await [Permission.microphone].request().then(
          (value) => setState(() {}),
        );

    agoraEngine = createAgoraRtcEngine();
    await agoraEngine?.initialize(const RtcEngineContext(
      appId: AgoraConstants.appId,
    ));

    agoraEngine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _isJoined = true;
          agoraEngine?.setEnableSpeakerphone(false);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _remoteUid = remoteUid;
          notifyText.value = "Connected";
          _startTimer();
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          showMessage("Remote user uid:$remoteUid left the channel");

          _remoteUid = null;
          notifyText.value = "Connecting";
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.teal,
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: callProvider.videoCallStream(
                isCaller: isCaller, channelName: channelName),
            builder: (context, snapshot) {
              String status = 'ringing';
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isNotEmpty) {
                  status = snapshot.data!.docs.first.data()['status'];
                  if (status == 'disconnected') {
                    Helpers.showToast("Call Disconnected");
                      Navigator.pop(context);
                    if (mounted && !_isCallDisconnected) {
                      _isCallDisconnected = true;
                    
                    }
                  }
                }
              }
              return SafeArea(
                child: agoraEngine != null
                    ? Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                const SizedBox(
                                  height: 40,
                                ),
                                Column(
                                  children: [
                                    Expanded(
                                        child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 40,
                                        ),
                                        Center(
                                          child: SizedBox(
                                            child: Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                          color: Colors.yellow,
                                                          width: 3)),
                                                  child: CircleAvatar(
                                                    radius: 100,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    child: InkWell(
                                                      radius: 100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      onTap: () {},
                                                      child: Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          child: const Icon(
                                                            Icons.person,
                                                            color: Colors.white,
                                                            size: 100,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 40,
                                        ),
                                        Center(
                                          child: Text(
                                            " Calling to ${peerName?.isNotEmpty??false? peerName : 'Caller'}",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        ValueListenableBuilder<String>(
                                            valueListenable: notifyText,
                                            builder: (context, snapshot, _) {
                                              return Center(
                                                child: Text(
                                                  snapshot,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              );
                                            }),
                                      ],
                                    )),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ValueListenableBuilder<bool>(
                                            valueListenable: speakerOn,
                                            builder: (context, snapshot, _) {
                                              return IconButton(
                                                  onPressed: () {
                                                    speakerOn.value = !snapshot;
                                                    agoraEngine
                                                        ?.setEnableSpeakerphone(
                                                            speakerOn.value);
                                                  },
                                                  icon: Icon(
                                                    snapshot
                                                        ? Icons.volume_up
                                                        : Icons.volume_up,
                                                    color: snapshot
                                                        ? Colors.white
                                                        : Colors.black
                                                            .withOpacity(0.8),
                                                  ));
                                            }),
                                        ValueListenableBuilder<bool>(
                                            valueListenable: micOn,
                                            builder: (context, snapshot, _) {
                                              return IconButton(
                                                  onPressed: () {
                                                    micOn.value = !snapshot;
                                                    agoraEngine
                                                        ?.muteLocalAudioStream(
                                                            !micOn.value);
                                                  },
                                                  icon: Icon(
                                                    snapshot
                                                        ? Icons.mic
                                                        : Icons.mic_off,
                                                    color: snapshot
                                                        ? Colors.white
                                                        : Colors.grey,
                                                  ));
                                            }),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        InkWell(
                                          onTap: () async{
                                         await   _leave();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                            child: const Icon(
                                              Icons.call_end,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: ValueListenableBuilder<String>(
                                        valueListenable: remainingTime,
                                        builder: (context, snapshot, _) {
                                          if (snapshot == "") {
                                            return const SizedBox();
                                          }
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(
                                              snapshot,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          );
                                        }),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              );
            }),
      ),
    );
  }

  Future<void> _join() async {
    ChannelMediaOptions options = const ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    await agoraEngine
        ?.joinChannel(
          token: token,
          channelId: channelName ?? '',
          options: options,
          uid: uid,
        )
        .then(
          (value) {},
        )
        .onError(
      (error, stackTrace) {
        Helpers.showToast("Failed to join channel: $error");
      },
    );
  }

  Future<void> _leave() async {


    _isCallDisconnected = true;
    await FirebaseRepo().createOrUpdateCallDocument(
        callerId: currentUserId,
        callerName: callerName,
        receiverName: receiverName,
        channelId: channelName ?? '',
        receiverId: widget.params.receiverId ?? "",
        status: 'disconnected',
        callType: callType);
    _isJoined = false;
    _remoteUid = null;
    agoraEngine?.leaveChannel();

    timer?.cancel();
         if (mounted) {
      Navigator.pop(context);
    }
  }

  _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remainingTime.value = Helpers.convert(timeInSec++);
    });
  }

  @override
  void dispose() {

    agoraEngine?.release();
    super.dispose();
  }
}
