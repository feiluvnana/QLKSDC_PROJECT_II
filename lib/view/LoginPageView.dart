import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_ii/controller/LoginPageController.dart';

class LoginPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: Future.delayed(const Duration(seconds: 4)),
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
            return GetBuilder<LoginPageController>(builder: (controller) {
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
                            border: Border.all(color: const Color(0xFF000000)),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            color: const Color(0xaaffffff)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Form(
                                key: _formKey,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 16),
                                        child: TextFormField(
                                          controller:
                                              controller.usernameController,
                                          decoration: const InputDecoration(
                                            labelText: "Tài khoản",
                                            labelStyle: TextStyle(
                                                color: Colors.black87),
                                            floatingLabelStyle:
                                                TextStyle(color: Colors.blue),
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if ((value?.length)! < 5) {
                                              return "Tài khoản cần dài ít nhất 5 ký tự.";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 16),
                                        child: TextFormField(
                                          controller:
                                              controller.passwordController,
                                          decoration: const InputDecoration(
                                            labelText: "Mật khẩu",
                                            labelStyle: TextStyle(
                                                color: Colors.black87),
                                            floatingLabelStyle:
                                                TextStyle(color: Colors.blue),
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: (value) {
                                            if ((value?.length)! < 6 ||
                                                !RegExp(r"^(?=.*?[A-Za-z])(?=.*?[0-9]).{6,}$")
                                                    .hasMatch(value!)) {
                                              return "Mật khẩu cần dài ít nhất 6 ký tự và có cả chữ lẫn số.";
                                            }
                                            return null;
                                          },
                                          obscureText: true,
                                        ),
                                      ),
                                    ])),
                            Container(
                              padding: const EdgeInsets.all(8),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() != true)
                                    return;
                                  controller.authenticate();
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
    );
  }
}
