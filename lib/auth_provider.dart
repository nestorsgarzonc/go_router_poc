// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  void setAuthenticated() {
    state = const AuthState(status: AuthStatus.authenticated);
  }

  void setUnauthenticated() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

enum AuthStatus {
  authenticated,
  unauthenticated,
  unknown;

  bool get isAuthenticated => this == AuthStatus.authenticated;
}

@immutable
class AuthState {
  const AuthState({
    required this.status,
  });

  final AuthStatus status;

  factory AuthState.initial() => const AuthState(status: AuthStatus.unauthenticated);

  @override
  bool operator ==(covariant AuthState other) {
    if (identical(this, other)) return true;

    return other.status == status;
  }

  @override
  int get hashCode => status.hashCode;
}
