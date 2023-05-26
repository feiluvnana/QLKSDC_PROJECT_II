import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/dependencies/internal_storage.dart';
import 'generated/l10n.dart';
import 'package:go_router/go_router.dart';
import 'view/home_page_view.dart';
import 'view/login_page_view.dart';
import 'view/InformationPageView.dart';

void main() {
  Future.delayed(const Duration(seconds: 0), () async {
    InternalStorage.init();
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
        redirect: (context, state) async =>
            ((await SharedPreferences.getInstance()).getString("sessionID") !=
                    null)
                ? "/home"
                : null),
    GoRoute(
        path: "/home",
        builder: (context, state) => Title(
            color: const Color(0xff68b6ef),
            title: "Trang chủ",
            child: const HomePage()),
        redirect: (context, state) async =>
            ((await SharedPreferences.getInstance()).getString("sessionID") ==
                    null)
                ? "/login"
                : null),
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
            (GetIt.I<InternalStorage>().read("roomGroupsList") == null ||
                    GetIt.I<InternalStorage>().read("servicesList") == null)
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
