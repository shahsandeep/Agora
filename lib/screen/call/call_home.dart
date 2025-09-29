import 'package:flutter/material.dart';

import 'caller_screen.dart';
import 'recieve_call_screen.dart';

class CallHome extends StatelessWidget {
  const CallHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.person_2,
          size: 100,
          color: Colors.green,
        ),
        const Text(
          'Please select your role.',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 60,
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CallerScreen(
                            isCaller: true,
                          )));
                },
                child: const Text('I am a caller',
                    style: TextStyle(color: Colors.white)),
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
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RecieveCallScreen()));
                },
                child: const Text('I am a receiver',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
        const Text(
            'Note: Please be on receiver screen to get call from caller...')
      ],
    );
  }
}
