import 'package:Unio/src/utilities/global.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert' as convert;
import '../../config/ui_icons.dart';
import '../widgets/SocialMediaWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Unio/main.dart';
import 'package:intl/intl.dart';

class SignInWidget extends StatefulWidget {
  @override
  _SignInWidgetState createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  bool _showPassword = false;
  final myEmailController = TextEditingController();
  final myPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<String> attemptLogin(String email, String password) async {
    var res = await http.post(Uri.parse(SERVER_DOMAIN + 'login'),
        body: {'email': email, 'password': password});
    if (res.statusCode == 200) return res.body;
    return null;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                  margin: EdgeInsets.symmetric(vertical: 65, horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).primaryColor,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).hintColor.withOpacity(0.2),
                            offset: Offset(0, 10),
                            blurRadius: 20)
                      ]),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 25),
                        Text('Sign In',
                            style: Theme.of(context).textTheme.display2),
                        SizedBox(height: 20),
                        new TextFormField(
                          validator: (input) =>
                              !input.contains('@') ? 'Not a valid email' : null,
                          controller: myEmailController,
                          style: TextStyle(color: Theme.of(context).focusColor),
                          keyboardType: TextInputType.emailAddress,
                          decoration: new InputDecoration(
                            hintText: 'Email Address',
                            hintStyle: Theme.of(context).textTheme.body1.merge(
                                  TextStyle(
                                      color: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.6)),
                                ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.2))),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).focusColor)),
                            prefixIcon: Icon(
                              UiIcons.envelope,
                              color:
                                  Theme.of(context).focusColor.withOpacity(0.6),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        new TextFormField(
                          validator: (input) => input.trim().length < 3
                              ? 'Not a valid password'
                              : null,
                          controller: myPasswordController,
                          style: TextStyle(color: Theme.of(context).focusColor),
                          keyboardType: TextInputType.text,
                          obscureText: !_showPassword,
                          decoration: new InputDecoration(
                            hintText: 'Password',
                            hintStyle: Theme.of(context).textTheme.body1.merge(
                                  TextStyle(
                                      color: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.6)),
                                ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.2))),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).focusColor)),
                            prefixIcon: Icon(
                              UiIcons.padlock_1,
                              color:
                                  Theme.of(context).focusColor.withOpacity(0.6),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                              color:
                                  Theme.of(context).focusColor.withOpacity(0.4),
                              icon: Icon(_showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        FlatButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot your password ?',
                            style: Theme.of(context).textTheme.body1,
                          ),
                        ),
                        SizedBox(height: 30),
                        FlatButton(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 70),
                          onPressed: () async {
                            EasyLoading.show(status: 'loading...');
                            storage.deleteAll();
                            var email = myEmailController.text;
                            var password = myPasswordController.text;
                            var jwt = await attemptLogin(email, password);
                            var data = convert.jsonDecode(jwt);

                            if (jwt != null) {
                              if (data['success'] == false) {
                                EasyLoading.dismiss();
                                showOkAlertDialog(
                                  context: context,
                                  title: 'Invalid username or password!',
                                );
                              } else {
                                dynamic date =
                                    data['data']['biodata']['birth_date'];

                                DateTime formattedDate;

                                if (date != null) {
                                  DateTime date2 = DateTime.parse(date);
                                  formattedDate = DateTime.parse(
                                      DateFormat('yyyy-MM-dd').format(date2));
                                } else {
                                  formattedDate = DateTime(2000, 01, 01);
                                }

                                var authId = data['data']['id'].toString();

                                Global.instance.authId = authId;
                                Global.instance.apiToken =
                                    data['data']['token']['api_token'];
                                Global.instance.authName =
                                    data['data']['biodata']['fullname'];
                                Global.instance.authEmail =
                                    data['data']['email'];
                                Global.instance.authPhone =
                                    data['data']['phone'];
                                Global.instance.authGender =
                                    data['data']['biodata']['gender'];
                                Global.instance.authPicture =
                                    data['data']['image_path'];
                                Global.instance.authAddress =
                                    data['data']['biodata']['address'];
                                Global.instance.authSchool =
                                    data['data']['biodata']['school_origin'];
                                Global.instance.authGraduate =
                                    data['data']['biodata']['graduation_year'];
                                Global.instance.authAddress =
                                    data['data']['biodata']['address'];
                                Global.instance.authBirthDate = formattedDate;
                                Global.instance.authBirthPlace =
                                    data['data']['biodata']['birth_place'];
                                Global.instance.authIdentity = data['data']
                                        ['biodata']['identity_number']
                                    .toString();
                                Global.instance.authReligion =
                                    data['data']['biodata']['religion'];

                                // add hc to global
                                Global.instance.authHc =
                                    data['data']['biodata']['hc'];

                                storage.write(
                                    key: 'authId', value: authId ?? '1');
                                storage.write(
                                    key: 'apiToken',
                                    value: data['data']['token']['api_token']);
                                storage.write(
                                    key: 'authEmail',
                                    value: data['data']['email'] ?? '-');
                                storage.write(
                                    key: 'authName',
                                    value: data['data']['biodata']
                                            ['fullname'] ??
                                        '-');
                                storage.write(
                                    key: 'authPicture',
                                    value: data['data']['image_path'] ?? '-');
                                storage.write(
                                    key: 'authPhone',
                                    value: data['data']['phone'] ?? '-');
                                storage.write(
                                    key: 'authGender',
                                    value: data['data']['biodata']['gender'] ??
                                        '-');
                                storage.write(
                                    key: 'authAddress',
                                    value: data['data']['biodata']['address'] ??
                                        '-');
                                storage.write(
                                    key: 'authGraduate',
                                    value: data['data']['biodata']
                                            ['graduation_year'] ??
                                        '-');
                                storage.write(
                                    key: 'authSchool',
                                    value: data['data']['biodata']
                                            ['school_origin'] ??
                                        '-');
                                storage.write(
                                    key: 'authBirthDate',
                                    value: formattedDate.toString());
                                storage.write(
                                    key: 'authBirthPlace',
                                    value: data['data']['biodata']
                                            ['birth_place'] ??
                                        '-');
                                storage.write(
                                    key: 'authIdentity',
                                    value: data['data']['biodata']
                                                ['identity_number']
                                            .toString() ??
                                        '-');
                                storage.write(
                                    key: 'authReligion',
                                    value: data['data']['biodata']
                                            ['religion'] ??
                                        '-');

                                // add hc to storage
                                storage.write(
                                    key: 'authHc',
                                    value:
                                        data['data']['biodata']['hc'] ?? '-');

                                EasyLoading.dismiss();

                                Navigator.of(context).popUntil(
                                    (route) => !route.navigator.canPop());
                                Navigator.of(context)
                                    .pushReplacementNamed('/Tabs');
                              }
                            } else {
                              EasyLoading.dismiss();
                              showOkAlertDialog(
                                context: context,
                                title: 'Invalid username or password!',
                              );
                            }
                          },
                          child: Text(
                            'Login',
                            style: Theme.of(context).textTheme.title.merge(
                                  TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                          ),
                          color: Theme.of(context).accentColor,
                          shape: StadiumBorder(),
                        ),
                        SizedBox(height: 50),
                        Text(
                          'Or using social media',
                          style: Theme.of(context).textTheme.body1,
                        ),
                        SizedBox(height: 20),
                        new SocialMediaWidget()
                      ],
                    ),
                  ),
                ),
              ],
            ),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/SignUp');
              },
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.title.merge(
                        TextStyle(color: Theme.of(context).primaryColor),
                      ),
                  children: [
                    TextSpan(text: 'Don\'t have an account ?'),
                    TextSpan(
                        text: ' Sign Up',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
