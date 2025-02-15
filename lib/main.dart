import 'package:Unio/src/providers/authentication.dart';
import 'package:Unio/src/providers/countries.dart';
import 'package:Unio/src/providers/level.dart';
import 'package:Unio/src/service/navigation_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart' as config;
import 'package:flutter/material.dart';
import 'route_generator.dart';

void main() => runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ChangeNotifierProvider(create: (_) => LevelProvider()),
      ChangeNotifierProvider(create: (_) => CountryProvider()),
    ],
    child: MyApp())
);


String cari_keyword = "";
String cari_query = "";

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'UNIO',
      initialRoute: '/',
      navigatorKey: NavigationService.instance.navigationKey,
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: Color(0xFF252525),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF2C2C2C),
        accentColor: config.Colors().mainDarkColor(1),
        hintColor: config.Colors().secondDarkColor(1),
        focusColor: config.Colors().accentDarkColor(1),
        textTheme: TextTheme(
          button: TextStyle(color: Color(0xFF252525)),
          headline: TextStyle(
              fontSize: 20.0, color: config.Colors().secondDarkColor(1)),
          display1: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: config.Colors().secondDarkColor(1)),
          display2: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: config.Colors().secondDarkColor(1)),
          display3: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w700,
              color: config.Colors().mainDarkColor(1)),
          display4: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w300,
              color: config.Colors().secondDarkColor(1)),
          subhead: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              color: config.Colors().secondDarkColor(1)),
          title: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: config.Colors().mainDarkColor(1)),
          body1: TextStyle(
              fontSize: 12.0, color: config.Colors().secondDarkColor(1)),
          body2: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: config.Colors().secondDarkColor(1)),
          caption: TextStyle(
              fontSize: 12.0, color: config.Colors().secondDarkColor(0.7)),
        ),
      ),
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: Colors.white,
        brightness: Brightness.light,
        accentColor: config.Colors().mainColor(1),
        focusColor: config.Colors().textSecondeColor(1),
        hintColor: config.Colors().textAccentColor(1),
        textTheme: TextTheme(
          button: TextStyle(color: Colors.white),
          headline: TextStyle(
              fontSize: 20.0, color: config.Colors().textSecondeColor(1)),
          display1: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: config.Colors().textSecondeColor(1)),
          display2: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: config.Colors().textSecondeColor(1)),
          display3: TextStyle(
              fontSize: 22.0, fontWeight: FontWeight.w700, color: Colors.white),
          display4: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.w300,
              color: config.Colors().textSecondeColor(1)),
          subhead: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w500,
              color: config.Colors().textSecondeColor(1)),
          title: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: config.Colors().textMainColor(1)),
          body1: TextStyle(
              fontSize: 12.0, color: config.Colors().textSecondeColor(1)),
          body2: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: config.Colors().textSecondeColor(1)),
          caption: TextStyle(
              fontSize: 12.0, color: config.Colors().textAccentColor(0.6)),
        ),
      ),
      builder: EasyLoading.init(),
    );
  }
}
