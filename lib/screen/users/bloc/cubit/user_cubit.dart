import 'package:agora_call/api/api.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../models/user_model.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final ApiCalls _apiCalls;
  UserCubit(this._apiCalls) : super(UserInitial());
  Future<void> fetchUsers() async {
    emit(state.copyWith(status: UserStatus.loading));
    try {
      final users = await _apiCalls.fetchUsers(onUpdated: (users) {
        emit(state.copyWith(status: UserStatus.loaded, users: users));
      });
      emit(state.copyWith(status: UserStatus.loaded, users: users));
    } catch (e) {
      emit(state.copyWith(status: UserStatus.error, error: e.toString()));
    }
  }
}
