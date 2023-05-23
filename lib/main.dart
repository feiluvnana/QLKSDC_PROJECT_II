import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:project_ii/utils/InternalStorage.dart';
import 'generated/l10n.dart';
import 'package:go_router/go_router.dart';
import 'view/home_page_view.dart';
import 'view/login_page_view.dart';
import 'view/InformationPageView.dart';
import 'binding/MyBinding.dart';

void main() {
  Future.delayed(const Duration(seconds: 0), () {
    MyBinding().dependencies();
    GetStorage.init();
    WidgetsFlutterBinding.ensureInitialized();
  }).then((value) => runApp(ProjectII()));
}

class ProjectII extends StatelessWidget {
  ProjectII({super.key});

  final _router = GoRouter(initialLocation: "/login", routes: [
    GoRoute(path: "/", builder: (context, state) => Container()),
    GoRoute(
        path: "/login",
        builder: (context, state) => Title(
            color: const Color(0xff68b6ef),
            title: "Đăng nhập",
            child: LoginPage()),
        redirect: (context, state) =>
            (GetStorage().read("sessionID") != null) ? "/home" : null),
    GoRoute(
        path: "/home",
        builder: (context, state) => Title(
            color: const Color(0xff68b6ef),
            title: "Trang chủ",
            child: const HomePage()),
        redirect: (context, state) =>
            (GetStorage().read("sessionID") == null) ? "/login" : null),
    GoRoute(
        path: "/info",
        builder: (context, state) {
          return Title(
              color: const Color(0xff68b6ef),
              title: "Thông tin",
              child: InformationPage(
                  ridx: int.parse(state.queryParameters["rid"]!),
                  oidx: int.parse(state.queryParameters["oid"]!)));
        },
        redirect: (context, state) =>
            (Get.find<InternalStorage>().read("roomGroupsList") == null ||
                    Get.find<InternalStorage>().read("servicesList") == null)
                ? "/home"
                : null),
  ]);

  @override
  Widget build(BuildContext context) {
    S.load(const Locale("vi", "VN"));
    return MaterialApp.router(
      routerConfig: _router,
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
    );
  }
}
