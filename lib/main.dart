import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'generated/l10n.dart';
import 'view/home_page_view.dart';
import 'view/login_page_view.dart';
import 'view/InformationPageView.dart';
import 'binding/MyBinding.dart';

void main() {
  Future.delayed(const Duration(seconds: 0), () {
    MyBinding().dependencies();
    GetStorage.init();
    WidgetsFlutterBinding.ensureInitialized();
  }).then((value) => runApp(const ProjectII()));
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
          curve: Curves.easeOutExpo,
        ),
        GetPage(
          name: "/home",
          page: () => Title(
              color: const Color(0xff68b6ef),
              title: "Trang chủ",
              child: const HomePage()),
          title: "Trang chủ",
          curve: Curves.easeOutExpo,
        ),
        GetPage(
            name: "/info",
            page: () => Title(
                color: const Color(0xff68b6ef),
                title: "Thông tin",
                child: const InformationPage()),
            curve: Curves.easeOutExpo),
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
