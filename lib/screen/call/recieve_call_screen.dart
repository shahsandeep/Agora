import 'package:agora_call/service/firebase_service.dart';
import 'package:agora_call/screen/call/audio_call.dart';

import 'package:agora_call/screen/call/video_call.dart';
import 'package:agora_call/utils/const/const.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/agora_model.dart';
import '../../utils/helper/helper.dart';

class RecieveCallScreen extends StatefulWidget {
  const RecieveCallScreen({super.key});

  @override
  State<RecieveCallScreen> createState() => _RecieveCallScreenState();
}

OverlayEntry? _overlayEntry;

class _RecieveCallScreenState extends State<RecieveCallScreen> {
  final player = AudioPlayer();

  Future<void> showOverlay(Function() onCallPickup, Function() onCallEnd,
      String userName, String callType) async {
    if (_overlayEntry != null) return; // Prevents duplicate overlays
    await player.setReleaseMode(ReleaseMode.loop);

    player.play(
      AssetSource('mp3/ring_audio.mp3'),
    );

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: Material(
          color: Colors.teal,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.teal,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, color: Colors.white, size: 200.0),
                const SizedBox(height: 40.0),
                Text(
                  'Incoming $callType Call...',
                  style: const TextStyle(color: Colors.white, fontSize: 30.0),
                ),
                const SizedBox(height: 40.0),
                Text(
                  userName,
                  style: const TextStyle(color: Colors.white, fontSize: 26.0),
                ),
                const SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                          callType.toLowerCase() == 'video'
                              ? Icons.video_call
                              : Icons.call,
                          color: Colors.green,
                          size: 40.0),
                      onPressed: onCallPickup,
                    ),
                    Ink(
                      child: IconButton(
                        icon: const Icon(Icons.call_end,
                            color: Colors.red, size: 40.0),
                        onPressed: onCallEnd,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    AgoraConstants.navigatorKey.currentState?.overlay?.insert(_overlayEntry!);
  }

  removeOverlay() {
    player.stop();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  _handleCall(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      String? currentUserId) {
    QueryDocumentSnapshot<Map<String, dynamic>>? ringSnapshot;
    for (var i in snapshot.data!.docs) {
      if (i.data()['status'] == 'ringing' &&
          i.data()['receiverId'] == currentUserId) {
        ringSnapshot = i;
        break;
      }
    }


    String? status = ringSnapshot?.data()['status'];
    String? receiverId = ringSnapshot?.data()['receiverId'];
 

 
    if (status == 'ringing' && receiverId == currentUserId) {
      String callerName = ringSnapshot?.data()['callerName'];

      Helpers.showToast("Incoming Call");
      showOverlay(() {
        final String? callerId = ringSnapshot?.data()['callerId'];
        final String? callerName = ringSnapshot?.data()['callerName'];
        final String? channelId = ringSnapshot?.data()['channelName'];
        final String? callType = ringSnapshot?.data()['callType'];

        removeOverlay();

        if (callType == 'voice') {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AgoraAudioCall(
                    params: AgoraCallParamsModel(
                      callerId: callerId ?? '',
                      callerName: callerName ?? '',
                      channelName: channelId ?? '',
                      receiverId: receiverId ?? '',
                      tempToken: AgoraConstants.token,
                    ),
                    isCaller: false,
                  )));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AgoraVideoCall(
                    params: AgoraCallParamsModel(
                      callerId: callerId ?? '',
                      callerName: callerName ?? '',
                      channelName: channelId ?? '',
                      receiverId: receiverId ?? '',
                      tempToken: AgoraConstants.token,
                    ),
                    isCaller: false,
                  )));
        }
      }, () async{
        final String? callerId = ringSnapshot?.data()['callerId'];
        final String? channelId = ringSnapshot?.data()['channelName'];
        final String? receiverId = ringSnapshot?.data()['receiverId'];
        final String? callType = ringSnapshot?.data()['callType'];
        final String? receiverName = ringSnapshot?.data()['receiverName'];
       await FirebaseRepo().createOrUpdateCallDocument(
            callerId: callerId ?? "",
            callerName: callerName,
            receiverName: receiverName ?? '',
            channelId: channelId ?? '',
            receiverId: receiverId ?? '',
            status: 'disconnected',
            callType: callType ?? '');
        removeOverlay();
      }, callerName, ringSnapshot?.data()['callType']);
    } else {
      if (_overlayEntry!=null && player.state == PlayerState.playing) {
  Helpers.showToast("Call Disconnected");
}
      removeOverlay();
    }
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
          }
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Recieve Call Screen'),
            centerTitle: true,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Please wait for the call...',
                    style: TextStyle(fontSize: 20.0)),
              ],
            ),
          ),
        );
      },
    );
  }
}
