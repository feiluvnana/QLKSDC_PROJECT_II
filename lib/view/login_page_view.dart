import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ii/blocs/login_page_bloc.dart';

class LoginPage extends StatelessWidget {
  final loadingEntry = OverlayEntry(
    builder: (context) => Container(
      color: Colors.black54,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Align(
        child: Container(
            width: 200,
            height: 200,
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator()),
                Text("Đang xác thực...")
              ],
            )),
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
              precacheImage(const AssetImage("images/logo.png"), context),
              precacheImage(
                  const AssetImage("images/loginBackground.jpg"), context)
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("images/logo.png"),
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                      const Text('Đang tải...'),
                    ],
                  ),
                );
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
                                            print(DateTime.now()
                                                .millisecondsSinceEpoch);
                                            context.read<LoginPageBloc>().add(
                                                SubmitButtonPressedEvent(
                                                    _usernameController.text,
                                                    _passwordController.text));
                                            print(DateTime.now()
                                                .millisecondsSinceEpoch);
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
    return BlocBuilder<LoginPageBloc, LoginState>(
        buildWhen: (previous, current) => previous.username != current.username,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: TextFormField(
              controller: usernameController,
              validator: (value) {
                if (value == null) return "Không để trống tài khoản";
                if (value.isEmpty) return "Không để trống tài khoản";
                if (!RegExp(r"^\w{5,}$").hasMatch(value)) {
                  return "Tài khoản chỉ chứa chữ cái hoặc số và dài hơn 5 ký tự";
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: "Tài khoản",
                labelStyle: TextStyle(color: Colors.black87),
                errorMaxLines: 2,
                floatingLabelStyle: TextStyle(color: Colors.blue),
                border: OutlineInputBorder(),
              ),
            ),
          );
        });
  }
}

class PasswordInput extends StatelessWidget {
  final TextEditingController passwordController;

  const PasswordInput({super.key, required this.passwordController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginPageBloc, LoginState>(
        buildWhen: (previous, current) => previous.password != current.password,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: TextFormField(
              controller: passwordController,
              obscureText: true,
              validator: (value) {
                if (value == null) return "Không để trống mật khẩu";
                if (value.isEmpty) return "Không để trống mật khẩu";
                if (!RegExp(r"^\w{8,}$").hasMatch(value)) {
                  return "Mật khẩu chỉ chứa chữ cái số và dài hơn 8 ký tự";
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                labelStyle: TextStyle(color: Colors.black87),
                floatingLabelStyle: TextStyle(color: Colors.blue),
                border: OutlineInputBorder(),
              ),
            ),
          );
        });
  }
}
