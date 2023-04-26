import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:project_ii/controller/AuthController.dart';
import 'package:project_ii/view/HomePageView.dart';
import 'package:project_ii/view/LoginPageView.dart';
import 'binding/AuthBinding.dart';
import 'dart:html' as html;

import 'generated/l10n.dart';
import 'middleware/AuthMiddleware.dart';
import 'middleware/AvoidReturningMiddleware.dart';
import 'view/InformationPageView.dart';

void main() async {
  AuthBinding().dependencies();
  html.window.onBeforeUnload.listen((event) async {
    print("out");
    await GetConnect().post(
      "http://localhost/php-crash/logout.php",
      FormData({"sessionID": Get.find<AuthController>().sessionID}),
    );
  });
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProjectII());
}

class ProjectII extends StatelessWidget {
  const ProjectII({super.key});

  @override
  Widget build(BuildContext context) {
    S.load(const Locale("vi", "VN"));
    return GetMaterialApp(
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => Title(
            color: const Color(0xff89b4f7),
            title: "Trang không tồn tại",
            child: const Text("Trang không tồn tại")),
      ),
      getPages: [
        GetPage(
          name: "/login",
          page: () => Title(
              color: const Color(0xff89b4f7),
              title: "Đăng nhập",
              child: LoginPage()),
          title: "Đăng nhập",
          middlewares: [AvoidReturningMiddleware()]
        ),
        GetPage(
            name: "/home",
            page: () => Title(
                color: const Color(0xff89b4f7),
                title: "Trang chủ",
                child: const HomePage()),
            title: "Trang chủ",
            middlewares: [
              AuthMiddleware()
            ],
            children: [
              GetPage(
                  name: "/info",
                  page: () => Title(
                      color: const Color(0xff89b4f7),
                      title: "Thông tin",
                      child: const InformationPage()))
            ]),
      ],
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: "Arial",
          primarySwatch: const MaterialColor(0xff89b4f7, {
            50: Color(0xff89b4f7),
            100: Color(0xff89b4f7),
            200: Color(0xff89b4f7),
            300: Color(0xff89b4f7),
            400: Color(0xff89b4f7),
            500: Color(0xff89b4f7),
            600: Color(0xff89b4f7),
            700: Color(0xff89b4f7),
            800: Color(0xff89b4f7),
            900: Color(0xff89b4f7),
          })),
      initialRoute: "/login",
    );
  }
}
