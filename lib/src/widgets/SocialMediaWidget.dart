import 'dart:convert';
import 'dart:io';

import 'package:Unio/src/utilities/global.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialMediaWidget extends StatelessWidget {
  const SocialMediaWidget({
    Key key,
  }) : super(key: key);

  void _launchURL(url) async {
    await canLaunch(url) ? await launch(url) : throw 'Could not launch url';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 45,
          height: 45,
          child: InkWell(
            onTap: () {
              _facebookLogin(context);
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (BuildContext context) => WebViewExample()));
              // _launchURL(
              //     'https://primavisiglobalindo.net/unio/public/auth/facebook');
            },
            child: Image.asset('img/facebook.png'),
          ),
        ),
        SizedBox(width: 10),
        // SizedBox(
        //   width: 45,
        //   height: 45,
        //   child: InkWell(
        //     onTap: () {},
        //     child: Image.asset('img/twitter.png'),
        //   ),
        // ),
        // SizedBox(width: 10),
        SizedBox(
          width: 45,
          height: 45,
          child: InkWell(
            onTap: () {
              _handleSignIn(context);
            },
            child: Image.asset('img/google-plus.png'),
          ),
        ),
        // SizedBox(width: 10),
        // SizedBox(
        //   width: 45,
        //   height: 45,
        //   child: InkWell(
        //     onTap: () {},
        //     child: Image.asset('img/linkedin.png'),
        //   ),
        // )
      ],
    );
  }

  void _facebookLogin(BuildContext context) async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(Uri.parse(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token'));
        final profile = json.decode(graphResponse.body);

        print(profile);
        var email = profile.containsKey('email') ? profile['email'] : 'test';

        // showOkAlertDialog(context: context, message: profile['name']);
        _login(context, 'facebook', profile['id'], email, profile['name']);
        break;
      case FacebookLoginStatus.cancelledByUser:
        // showOkAlertDialog(context: context, message: "Login canceled");
        break;
      case FacebookLoginStatus.error:
        showOkAlertDialog(context: context, message: result.errorMessage);
        break;
    }
  }

  Future<void> _handleSignIn(BuildContext context) async {
    GoogleSignInAccount _currentUser;

    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );

    try {
      await _googleSignIn.signIn();
      _currentUser = _googleSignIn.currentUser;

      if (_currentUser == null) {
        showOkAlertDialog(
          context: context,
          title: 'User not found',
        );
      }

      print(_currentUser);

      _login(context, 'google', _currentUser.id, _currentUser.email, _currentUser.displayName);
    } catch (error) {
      print(error);
    }
  }

  void _login(context, _provider, _providerId, _providerEmail,
      _providerFullName) async {
    EasyLoading.show(status: 'loading...');
    storage.deleteAll();
    var res = await attemptLoginWithProvider(
        _provider, _providerId, _providerEmail, _providerFullName);
    print(res);

    if (res == null) {
      EasyLoading.dismiss();
      showOkAlertDialog(
        context: context,
        title:
            'Login using Social Accounts encounters an error for the moment. Try again later',
      );
    }

    var data = json.decode(res);

    if (data != null) {
      if (data['success'] == false) {
        EasyLoading.dismiss();
        showOkAlertDialog(
          context: context,
          title: 'Invalid username or password!',
        );
      } else {
        dynamic date = data['biodata']['birth_date'];

        DateTime formattedDate;

        if (date != null) {
          DateTime date2 = DateTime.parse(date);
          formattedDate =
              DateTime.parse(DateFormat('yyyy-MM-dd').format(date2));
        } else {
          formattedDate = null;
        }

        var authId = data['id'].toString();

        Global.instance.authId = authId;
        Global.instance.apiToken = data['api_token'];
        Global.instance.authName = data['biodata']['fullname'];
        Global.instance.authEmail = data['email'];
        Global.instance.authPhone = data['phone'];
        Global.instance.authGender = data['biodata']['gender'];
        Global.instance.authPicture = data['image_path'];
        Global.instance.authAddress = data['biodata']['address'];
        Global.instance.authSchool = data['biodata']['school_origin'];
        Global.instance.authGraduate = data['biodata']['graduation_year'];
        Global.instance.authAddress = data['biodata']['address'];
        Global.instance.authBirthDate = formattedDate;
        Global.instance.authBirthPlace = data['biodata']['birth_place'];
        Global.instance.authIdentity =
            data['biodata']['identity_number'].toString();
        Global.instance.authReligion = data['biodata']['religion'];

        // add hc to global
        Global.instance.authHc = data['biodata']['hc'];

        storage.write(key: 'authId', value: authId);
        storage.write(key: 'apiToken', value: data['api_token']);
        storage.write(key: 'authEmail', value: data['email']);
        storage.write(key: 'authName', value: data['biodata']['fullname']);
        storage.write(key: 'authPicture', value: data['image_path']);
        storage.write(key: 'authPhone', value: data['phone']);
        storage.write(key: 'authGender', value: data['biodata']['gender']);
        storage.write(key: 'authAddress', value: data['biodata']['address']);
        storage.write(
            key: 'authGraduate', value: data['biodata']['graduation_year']);
        storage.write(
            key: 'authSchool', value: data['biodata']['school_origin']);
        storage.write(key: 'authBirthDate', value: formattedDate.toString());
        storage.write(
            key: 'authBirthPlace', value: data['biodata']['birth_place']);
        storage.write(
            key: 'authIdentity',
            value: data['biodata']['identity_number'].toString() ?? '');
        storage.write(key: 'authReligion', value: data['biodata']['religion']);

        // add hc to storage
        storage.write(key: 'authHc', value: data['biodata']['hc']);

        EasyLoading.dismiss();
        Navigator.of(context).popUntil((route) => !route.navigator.canPop());
        Navigator.of(context).pushReplacementNamed('/Tabs');
      }
    } else {
      EasyLoading.dismiss();
      showOkAlertDialog(
        context: context,
        title: 'Invalid Login',
      );
    }
  }

  Future<dynamic> attemptLoginWithProvider(
      String provider, dynamic id, String email, String fullName) async {
    // var url = "http://10.0.2.2:8000/api/";
    var url = SERVER_DOMAIN;

    var _e = email == '' ? null : email;

    var res = await http
        .post(Uri.parse(url + 'login-with-provider/$provider'), body: {
      'provider_id': id,
      'provider_email': _e,
      'provider_full_name': fullName,
    });

    print(res.toString());

    // if (res.statusCode == 200) return res.body;
    return res.body;
  }
}

// class WebViewExample extends StatefulWidget {
//   @override
//   WebViewExampleState createState() => WebViewExampleState();
// }

// class WebViewExampleState extends State<WebViewExample> {
//   @override
//   void initState() {
//     super.initState();
//     // Enable hybrid composition.
//     if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login Facebook'),
//       ),
//       body: WebView(
//         initialUrl: 'https://primavisiglobalindo.net/unio/public/auth/facebook',
//       ),
//     );
//   }
// }
