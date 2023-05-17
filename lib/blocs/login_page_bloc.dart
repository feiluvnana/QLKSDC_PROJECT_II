import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:project_ii/data/providers/authentication_provider.dart';
import 'package:rxdart/rxdart.dart';

abstract class LoginPageEvent {}

class SubmitButtonPressedEvent extends LoginPageEvent {
  final String username, password;

  SubmitButtonPressedEvent(this.username, this.password);
}

class GotoHomePage extends LoginPageEvent {
  final BuildContext context;

  GotoHomePage(this.context);
}

class ErrorDialogRemove extends LoginPageEvent {}

enum AuthenticationState { unauthenticated, authenticated, authenticating }

class LoginState extends Equatable {
  final AuthenticationState state;
  final String username, password;
  final GlobalKey<FormState> formKey;
  const LoginState(
      {required this.state,
      required this.formKey,
      required this.username,
      required this.password});
  LoginState copyWith(
      {AuthenticationState? state, String? username, String? password}) {
    return LoginState(
        state: state ?? this.state,
        formKey: formKey,
        username: username ?? this.username,
        password: password ?? this.password);
  }

  @override
  List<Object?> get props => [state, username, password];
}

class LoginPageBloc extends Bloc<LoginPageEvent, LoginState> {
  LoginPageBloc()
      : super(LoginState(
            state: AuthenticationState.unauthenticated,
            formKey: GlobalKey<FormState>(),
            username: "",
            password: "")) {
    on<SubmitButtonPressedEvent>((event, emit) async {
      if (state.formKey.currentState?.validate() != true) {
        return;
      }
      emit(state.copyWith(state: AuthenticationState.authenticating));
      if (await AuthenticationProvider.authenticate(
          username: state.username, password: state.password)) {
        emit(state.copyWith(state: AuthenticationState.authenticated));
      } else {
        emit(state.copyWith(state: AuthenticationState.unauthenticated));
      }
    });
    on<GotoHomePage>((event, emit) {
      event.context.go("/home");
      close();
    });
  }

  @override
  void onTransition(Transition<LoginPageEvent, LoginState> transition) {
    super.onTransition(transition);
    print("[LoginPageBlock] $transition");
  }
}
