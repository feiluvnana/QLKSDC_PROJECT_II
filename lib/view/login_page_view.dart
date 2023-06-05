import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ii/blocs/login_page_bloc.dart';

import '../utils/validators/validators.dart';

class LoginPage extends StatelessWidget {
  final loadingEntry = OverlayEntry(
    builder: (context) => Scaffold(
      body: Container(
        color: Colors.black54,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Align(
          child: Container(
              width: 200,
              height: 200,
              color: Colors.white,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator()),
                  Text("Đang xác thực...")
                ],
              )),
        ),
      ),
    ),
  );
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginPageBloc(),
        child: FutureBuilder(
            future: Future.wait([
              precacheImage(
                  const AssetImage("images/loginBackground.jpg"), context)
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox();
              }
              return BlocConsumer<LoginPageBloc, LoginState>(
                  listenWhen: (previous, current) =>
                      previous.state != current.state,
                  listener: (context, state) {
                    if (state.state == AuthenticationState.authenticating) {
                      Overlay.of(context).insert(loadingEntry);
                    } else {
                      loadingEntry.remove();
                      if (state.state == AuthenticationState.authenticated) {
                        context
                            .read<LoginPageBloc>()
                            .add(GotoHomePage(context));
                      }
                    }
                  },
                  builder: (context, state) {
                    return Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("images/loginBackground.jpg")),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Expanded(child: SizedBox()),
                          Flexible(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF000000)),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  color: const Color(0xaaffffff)),
                              child: Form(
                                key: state.formKey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          UsernameInput(
                                              usernameController:
                                                  _usernameController),
                                          PasswordInput(
                                              passwordController:
                                                  _passwordController)
                                        ]),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          {
                                            context.read<LoginPageBloc>().add(
                                                SubmitButtonPressedEvent(
                                                    _usernameController.text,
                                                    _passwordController.text));
                                          }
                                        },
                                        child: const Text("Đăng nhập"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox())
                        ],
                      ),
                    );
                  });
            }),
      ),
    );
  }
}

class UsernameInput extends StatelessWidget {
  final TextEditingController usernameController;

  const UsernameInput({super.key, required this.usernameController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: TextFormField(
        controller: usernameController,
        validator: Validators().usernameValidator,
        onChanged: (value) => context
            .read<LoginPageBloc>()
            .add(UsernameChangedEvent(usernameController.text)),
        decoration: const InputDecoration(
          labelText: "Tài khoản",
          labelStyle: TextStyle(color: Colors.black87),
          errorMaxLines: 2,
          floatingLabelStyle: TextStyle(color: Colors.blue),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class PasswordInput extends StatelessWidget {
  final TextEditingController passwordController;

  const PasswordInput({super.key, required this.passwordController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: TextFormField(
        controller: passwordController,
        obscureText: true,
        validator: Validators().passwordValidator,
        onChanged: (value) => context
            .read<LoginPageBloc>()
            .add(PasswordChangedEvent(passwordController.text)),
        decoration: const InputDecoration(
          labelText: "Mật khẩu",
          labelStyle: TextStyle(color: Colors.black87),
          floatingLabelStyle: TextStyle(color: Colors.blue),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
