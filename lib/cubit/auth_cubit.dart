import 'package:agora_call/api/api.dart';
import 'package:agora_call/cubit/auth_state.dart';
import 'package:agora_call/services/shared_pref.dart';
import 'package:bloc/bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final ApiCalls apiCalls;
  final SharedPref sharedPreferences;

  AuthCubit({required this.apiCalls, required this.sharedPreferences}) : super(AuthState.initial());
  Future<void> isLoggedIn() async {
    final String? token = await sharedPreferences.getUserToken();
    if (token != null && token.isNotEmpty) {
      emit(AuthState.loggedIn());
    } else {
      emit(AuthState.loggedOut());
    }
  }
  Future<void> login({required String email, required String password}) async {
    emit(AuthState.loading());
    try {
      await apiCalls.login(email, password).then((value) async{
        await sharedPreferences.saveUserToken(value);
      },);

      emit(AuthState.loggedIn());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }


  Future<void> logout() async {
    emit(AuthState.loading());
    try {
   
      await sharedPreferences.deleteUserToken();
      emit(AuthState.loggedOut());
    } catch (e) {
      emit(AuthState.error(e.toString()));
    }
  }
}
