part of 'user_cubit.dart';

enum UserStatus { initial, loading, loaded, error }
class UserInitial extends UserState {}
class UserState {
  final UserStatus status;
  final List<UserModel>? users;
  final String? error;

  UserState({
    this.status = UserStatus.initial,
    this.users,
    this.error,
  });

  UserState copyWith({
    UserStatus? status,
    List<UserModel>? users,
    String? error,
  }) {
    return UserState(
      status: status ?? this.status,
      users: users ?? this.users,
      error: error ?? this.error,
    );
  }
}
