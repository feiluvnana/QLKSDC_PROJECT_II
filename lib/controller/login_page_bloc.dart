import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Transition;
import 'package:get_storage/get_storage.dart';
import 'package:project_ii/data/providers/authentication_provider.dart';
import 'package:project_ii/data/providers/room_group_data_provider.dart';
import 'package:rxdart/rxdart.dart';

abstract class LoginPageEvent {}

class SubmitButtonPressedEvent extends LoginPageEvent {}

class UsernameChangedEvent extends LoginPageEvent {
  final String username;
  UsernameChangedEvent({required this.username});
}

class PasswordChangedEvent extends LoginPageEvent {
  final String password;
  PasswordChangedEvent({required this.password});
}

class GotoHomePage extends LoginPageEvent {}

class ErrorDialogRemove extends LoginPageEvent {}

enum AuthenticationState { unauthenticated, authenticated, authenticating }

class LoginState extends Equatable {
  final AuthenticationState state;
  final String username, password;
  final bool error;
  const LoginState(
      {required this.state,
      required this.error,
      required this.username,
      required this.password});
  LoginState copyWith(
      {AuthenticationState? state,
      bool? error,
      String? username,
      String? password}) {
    return LoginState(
        state: state ?? this.state,
        error: error ?? this.error,
        username: username ?? this.username,
        password: password ?? this.password);
  }

  @override
  List<Object?> get props => [state, username, password, error];
}

class LoginPageBloc extends Bloc<LoginPageEvent, LoginState> {
  LoginPageBloc()
      : super(const LoginState(
            state: AuthenticationState.unauthenticated,
            error: false,
            username: "",
            password: "")) {
    on<SubmitButtonPressedEvent>((event, emit) async {
      emit(state.copyWith(state: AuthenticationState.authenticating));
      if (await AuthenticationProvider.authenticate(
          username: state.username, password: state.password)) {
        await RoomGroupDataProvider(
                currentMonth:
                    DateTime(DateTime.now().year, DateTime.now().month),
                today: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day))
            .getRoomGroups();
        emit(state.copyWith(
            state: AuthenticationState.authenticated, error: false));
      } else {
        emit(state.copyWith(
            state: AuthenticationState.unauthenticated, error: true));
      }
    },
        transformer: (events, mapper) =>
            events.debounceTime(const Duration(seconds: 3)).flatMap(mapper));
    on<UsernameChangedEvent>(
        (event, emit) => {emit(state.copyWith(username: event.username))});
    on<PasswordChangedEvent>(
        (event, emit) => {emit(state.copyWith(password: event.password))});
    on<GotoHomePage>((event, emit) => {close()});
  }

  @override
  void onTransition(Transition<LoginPageEvent, LoginState> transition) {
    super.onTransition(transition);
    print("[LoginPageBlock] $transition");
  }
}
