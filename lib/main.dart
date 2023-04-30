import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'generated/l10n.dart';
import 'view/HomePageView.dart';
import 'view/LoginPageView.dart';
import 'view/InformationPageView.dart';
import 'binding/MyBinding.dart';
import 'middleware/HomePageMiddleware.dart';
import 'middleware/LoginPageMiddleware.dart';

void main() async {
  MyBinding().dependencies();
  await GetStorage.init();
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
            color: const Color(0xff68b6ef),
            title: "Trang không tồn tại",
            child: const Text("Trang không tồn tại")),
      ),
      getPages: [
        GetPage(
            name: "/login",
            page: () => Title(
                color: const Color(0xff68b6ef),
                title: "Đăng nhập",
                child: LoginPage()),
            title: "Đăng nhập",
            middlewares: [AvoidReturningMiddleware()]),
        GetPage(
            name: "/home",
            page: () => Title(
                color: const Color(0xff68b6ef),
                title: "Trang chủ",
                child: const HomePage()),
            title: "Trang chủ",
            middlewares: [
              HomePageMiddleware()
            ],
            children: [
              GetPage(
                  name: "/info",
                  page: () => Title(
                      color: const Color(0xff68b6ef),
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
          primarySwatch: const MaterialColor(0xff68b6ef, {
            50: Color(0xff68b6ef),
            100: Color(0xff68b6ef),
            200: Color(0xff68b6ef),
            300: Color(0xff68b6ef),
            400: Color(0xff68b6ef),
            500: Color(0xff68b6ef),
            600: Color(0xff68b6ef),
            700: Color(0xff68b6ef),
            800: Color(0xff68b6ef),
            900: Color(0xff68b6ef),
          })),
      initialRoute: "/login",
    );
  }
}
