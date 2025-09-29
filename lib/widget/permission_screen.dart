
import 'package:agora_call/utils/helper/helper.dart';
import 'package:flutter/material.dart';

import '../screen/home/home.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Screen'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please enable microphone and camera permissions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        var statuses =
                            await Helpers.requestPermissions(context);
                        if (statuses['microphone'] !=
                            PermissionStatus.granted) {
                          if (context.mounted) {
                            Helpers.showPermissionDialog(context, 'Microphone');
                          }
                        } else if (statuses['camera'] !=
                            PermissionStatus.granted) {
                          if (context.mounted) {
                            Helpers.showPermissionDialog(context, 'Camera');
                          }
                        } else {}
                      },
                      child: const Text(
                        'Enable Permission',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        var statuses =
                            await Helpers.requestPermissions(context);
                        if (statuses['microphone'] ==
                                PermissionStatus.granted &&
                            statuses['camera'] == PermissionStatus.granted) {
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) {
                                  return const HomeScreen();
                                },
                              ),
                              (route) => false,
                            );
                          }
                        } else {
                          Helpers.showToast('Permission not granted');
                        }
                      },
                      child: const Text(
                        'Already Enabled? Click here',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
