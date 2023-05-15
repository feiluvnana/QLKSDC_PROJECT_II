import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:project_ii/controller/login_page_bloc.dart';

class LoginPage extends StatelessWidget {
  BuildContext? _storedContext;
  final loadingWidget = SizedBox(
      width: 200,
      height: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Padding(
              padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          Spacer(),
          Text("Đang xác thực...")
        ],
      ));
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
                  listener: (context, state) {
                if (state.state == AuthenticationState.authenticating) {
                  _storedContext = context;
                  showDialog(
                      context: context,
                      builder: (_) => Dialog(child: loadingWidget),
                      barrierDismissible: false);
                } else if (state.state == AuthenticationState.authenticated) {
                  Get.offNamed("/home");
                  context.read<LoginPageBloc>().close();
                } else if (_storedContext != null) {
                  Navigator.of(_storedContext!).pop();
                  _storedContext = null;
                }
              }, builder: (context, state) {
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
                              border:
                                  Border.all(color: const Color(0xFF000000)),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              color: const Color(0xaaffffff)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(mainAxisSize: MainAxisSize.min, children: [
                                UsernameInput(
                                    usernameController: _usernameController),
                                PasswordInput(
                                    passwordController: _passwordController)
                              ]),
                              Container(
                                padding: const EdgeInsets.all(8),
                                child: ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<LoginPageBloc>()
                                        .add(SubmitButtonPressedEvent());
                                  },
                                  child: const Text("Đăng nhập"),
                                ),
                              ),
                            ],
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
            child: TextField(
              controller: usernameController,
              onChanged: (value) => context
                  .read<LoginPageBloc>()
                  .add(UsernameChangedEvent(username: value)),
              decoration: const InputDecoration(
                labelText: "Tài khoản",
                labelStyle: TextStyle(color: Colors.black87),
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
            child: TextField(
              controller: passwordController,
              onChanged: (value) => context
                  .read<LoginPageBloc>()
                  .add(PasswordChangedEvent(password: value)),
              obscureText: true,
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
