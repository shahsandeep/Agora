import 'package:agora_call/api/api.dart';
import 'package:agora_call/bloc/cubit/auth_cubit.dart';
import 'package:agora_call/bloc/cubit/auth_state.dart';
import 'package:agora_call/models/user_model.dart';
import 'package:agora_call/screen/auth/login_screen.dart';
import 'package:agora_call/screen/splash/splash.dart';
import 'package:agora_call/screen/users/bloc/cubit/user_cubit.dart';
import 'package:agora_call/service/local_storage.dart';
import 'package:agora_call/service/shared_pref.dart';
import 'package:agora_call/utils/const/const.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox('localStorageBox');
  await Firebase.initializeApp();
  final localStorage = HiveLocalStorage();

  final apiCalls = ApiCalls(localStorage: localStorage );

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) =>
            AuthCubit(apiCalls:apiCalls, sharedPreferences: SharedPref()),
      ),
      BlocProvider(
        create: (context) => UserCubit(apiCalls),
      ),
    ],
    child: BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.isLoggedIn == false) {
          localStorage.clearAllData();
          AgoraConstants.navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: ConnectivityAppWrapper(
        app: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.teal.shade100,
              appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.teal,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              )),
          navigatorKey: AgoraConstants.navigatorKey,

          home: const SplashScreen(),

          builder: (buildContext, widget) {
            return ConnectivityWidgetWrapper(
              disableInteraction: true,
              height: 80,
              child: widget!,
            );
          },
        ),
      ),
    ),
  ));
}
