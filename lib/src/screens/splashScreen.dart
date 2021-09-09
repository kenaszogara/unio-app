import 'package:Unio/main.dart';
import 'package:Unio/src/models/uri_to_app.dart';
import 'package:Unio/src/providers/countries.dart';
import 'package:Unio/src/providers/level.dart';
import 'package:Unio/src/screens/signin.dart';
import 'dart:async';
import 'dart:io';
import 'package:Unio/src/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uni_links/uni_links.dart';
import '../screens/on_boarding.dart';
import 'package:Unio/src/utilities/global.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _initialUriIsHandled = false;
  Uri _initialUri;
  Uri _latestUri;
  Object _err;

  StreamSubscription _sub;
  UriToApp uriToApp = new UriToApp();
  bool isFromURI = false;

  @override
  void initState() {
    // storage.deleteAll();
    _handleInitialUri();
    _handleIncomingLinks();
    getAuthData();
    // TODO: implement initState
    super.initState();

    context.read<LevelProvider>().initLevel();
    context.read<CountryProvider>().initCountries();
  }

  getAuthData() async {
    var date = await storage.read(key: 'authBirthDate');
    print(date);
    print('lala');
    Global.instance.authId = await storage.read(key: 'authId');
    Global.instance.apiToken = await storage.read(key: 'apiToken');
    Global.instance.authName = await storage.read(key: 'authName');
    Global.instance.authEmail = await storage.read(key: 'authEmail');
    Global.instance.authGender = await storage.read(key: 'authGender');
    Global.instance.authPicture = await storage.read(key: 'authPicture');
    Global.instance.authPhone = await storage.read(key: 'authPhone');
    Global.instance.authAddress = await storage.read(key: 'authAddress');
    Global.instance.authSchool = await storage.read(key: 'authSchool');
    Global.instance.authGraduate = await storage.read(key: 'authGraduate');
    Global.instance.authBirthPlace = await storage.read(key: 'authBirthPlace');
    Global.instance.authBirthDate =
        date != 'null' ? DateTime.parse(date) : null;
    Global.instance.authIdentity = await storage.read(key: 'authIdentity');
    Global.instance.authHc = await storage.read(key: 'authHc');

    var countryId = await storage.read(key: 'authCountryId');
    Global.instance.authCountryId =
        countryId != null ? int.parse(countryId) : null;

    var authLevelId = await storage.read(key: 'authLevelId');
    Global.instance.authLevelId = authLevelId != null ? int.parse(authLevelId) : null;
  }

  // get initialUri
  /// Handle the initial Uri - the one the app was started with
  ///
  /// **ATTENTION**: `getInitialLink`/`getInitialUri` should be handled
  /// ONLY ONCE in your app's lifetime, since it is not meant to change
  /// throughout your app's life.
  ///
  /// We handle all exceptions, since it is called from initState.
  Future<void> _handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      print('_handleInitialUri called');
      try {
        final uri = await getInitialUri();
        if (uri == null) {
          print('no initial uri');
        } else {
          print('got initial uri: $uri');
          isFromURI = true;
          _latestUri = uri;
        }
        if (!mounted) return;
        setState(() => _initialUri = uri);
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('falied to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri');
        setState(() => _err = err);
      }
    }
  }

  /// Handle incoming links - the ones that the app will recieve from the OS
  /// while already started.
  void _handleIncomingLinks() {
    // It will handle app links while the app is already started - be it in
    // the foreground or in the background.
    _sub = getUriLinksStream().listen((Uri uri) {
      if (!mounted) return;
      print('got uri: $uri');
      setState(() {
        _latestUri = uri;
        isFromURI = true;
        _err = null;
      });
    }, onError: (Object err) {
      if (!mounted) return;
      print('got err: $err');
      setState(() {
        _latestUri = null;
        isFromURI = false;
        if (err is FormatException) {
          _err = err;
        } else {
          _err = null;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new SplashPage(
      seconds: 10,
      navigateAfterSeconds: isFromURI ? _latestUri : new OnBoardingWidget(),
      logo: SvgPicture.asset(
        'assets/icons/uniologoputih.svg',
        color: Colors.white,
        width: 40.0,
        height: 40.0,
      ),
      backgroundColor: Theme.of(context).accentColor.withOpacity(0.7),
      loaderColor: Colors.white,
    );
  }
}
