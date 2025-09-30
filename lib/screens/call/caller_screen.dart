import 'package:agora_call/models/agora_model.dart';

import 'package:agora_call/screens/call/audio_call.dart';
import 'package:agora_call/screens/call/video_call.dart';
import 'package:agora_call/utils/const/const.dart';
import 'package:flutter/material.dart';

class CallerScreen extends StatelessWidget {
  final bool isCaller;
  const CallerScreen({super.key, required this.isCaller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Caller Screen'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCaller) ...[
                Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AgoraAudioCall(
                            params: AgoraCallParamsModel(
                              receiverName: 'Reciever',
                              receiverId: '2',
                              tempToken: AgoraConstants.token,
                            ),
                            isCaller: true),
                      ));
                    },
                    title: const Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(
                          width: 6,
                        ),
                        Text('Audio Call to Reciever')
                      ],
                    ),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AgoraVideoCall(
                            params: AgoraCallParamsModel(
                              receiverName: 'Reciever',
                              receiverId: '2',
                              tempToken: AgoraConstants.token,
                            ),
                            isCaller: true),
                      ));
                    },
                    title: const Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(
                          width: 6,
                        ),
                        Text('Video Call to Reciever')
                      ],
                    ),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.video_call,
                          size: 30,
                        )
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ));
  }
}
