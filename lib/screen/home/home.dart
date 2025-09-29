import 'package:agora_call/screen/call/call_home.dart';
import 'package:agora_call/screen/call/caller_screen.dart';
import 'package:agora_call/widget/permission_screen.dart';
import 'package:agora_call/screen/call/recieve_call_screen.dart';
import 'package:agora_call/screen/users/users.dart';
import 'package:agora_call/utils/helper/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/cubit/auth_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    int _selectedIndex = 0;
    final List<Widget> _pages = [
    const CallHome(),
       const UsersScreen(),
    ];
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  _checkPermissions() async {
    Helpers.requestPermissions(context).then((status) {
      if (status['microphone'] != PermissionStatus.granted ||
          status['camera'] != PermissionStatus.granted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) {
            return const PermissionScreen();
          }),
          (Route<dynamic> route) => false,
        );
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(child: Text('Agora Call App by Sandeep Shah')),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white,),
            itemBuilder: (context) {
            return [
              const PopupMenuItem<int>(
                value: 0,
                child: Text("Logout"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              BlocProvider.of<AuthCubit>(context).logout();
            }
          },)
 
        
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(icon: Icon(Icons.call), label: "Calls"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Users"),
        
      ], 
            currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: _pages.elementAt(_selectedIndex),
        ),
      ),
    );
  }
}
