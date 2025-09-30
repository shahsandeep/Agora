import 'package:flutter/foundation.dart';

@immutable
class AuthState {
  final bool isLoggedIn;
  final String? error;
  final bool isLoading;

  const AuthState({
    required this.isLoggedIn,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory AuthState.initial() => const AuthState(isLoggedIn: false);

  factory AuthState.loggedIn() => const AuthState(isLoggedIn: true);

  factory AuthState.loggedOut() => const AuthState(isLoggedIn: false);
  factory AuthState.loading() => const AuthState(isLoggedIn: false, isLoading: true);

  factory AuthState.error(String error) =>
      AuthState(isLoggedIn: false, error: error);
}
