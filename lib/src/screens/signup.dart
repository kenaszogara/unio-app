import '../../config/ui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/SocialMediaWidget.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:Unio/main.dart';
import 'package:http/http.dart' as http;
import 'package:Unio/src/utilities/global.dart';

class SignUpWidget extends StatefulWidget {
  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  bool _showPassword = false;
  final myEmailController = TextEditingController();
  final myPasswordController = TextEditingController();
  //final myPasswordConfirmationController = TextEditingController();
  final myNameController = TextEditingController();
  final myPhoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _showMyDialog(String message, String route) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                if (route == 'signIn') {
                  Navigator.of(context).pushNamed('/SignIn');
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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
                  margin: EdgeInsets.fromLTRB(20, 70, 20, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).primaryColor,
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).hintColor.withOpacity(0.2),
                          offset: Offset(0, 10),
                          blurRadius: 20)
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 25),
                        Text('Sign Up',
                            style: Theme.of(context).textTheme.display2),
                        SizedBox(height: 20),
                        new TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Input Name';
                            }
                            return null;
                          },
                          controller: myNameController,
                          style: TextStyle(color: Theme.of(context).focusColor),
                          keyboardType: TextInputType.text,
                          decoration: new InputDecoration(
                            hintText: 'Full Name',
                            hintStyle: Theme.of(context).textTheme.body1.merge(
                                  TextStyle(
                                      color: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.4)),
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
                              UiIcons.user_1,
                              color:
                                  Theme.of(context).focusColor.withOpacity(0.4),
                            ),
                          ),
                        ),
                        new TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Input Email';
                            }
                            return null;
                          },
                          controller: myEmailController,
                          style: TextStyle(color: Theme.of(context).focusColor),
                          keyboardType: TextInputType.emailAddress,
                          decoration: new InputDecoration(
                            hintText: 'Email Address',
                            hintStyle: Theme.of(context).textTheme.body1.merge(
                                  TextStyle(
                                      color: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.4)),
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
                                  Theme.of(context).focusColor.withOpacity(0.4),
                            ),
                          ),
                        ),
                        new TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please input password';
                            }
                            return null;
                          },
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
                                          .withOpacity(0.4)),
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
                                  Theme.of(context).focusColor.withOpacity(0.4),
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
                        /*new TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please input password confirmation';
                            }
                            return null;
                          },
                          controller: myPasswordConfirmationController,
                          style: TextStyle(color: Theme.of(context).focusColor),
                          keyboardType: TextInputType.text,
                          obscureText: !_showPassword,
                          decoration: new InputDecoration(
                            hintText: 'Confirm Password',
                            hintStyle: Theme.of(context).textTheme.body1.merge(
                                  TextStyle(
                                      color: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.4)),
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
                                  Theme.of(context).focusColor.withOpacity(0.4),
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
                        ),*/
                        new TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please Input Phone';
                            }
                            return null;
                          },
                          controller: myPhoneController,
                          style: TextStyle(color: Theme.of(context).focusColor),
                          keyboardType: TextInputType.number,
                          decoration: new InputDecoration(
                            hintText: 'Phone Number',
                            hintStyle: Theme.of(context).textTheme.body1.merge(
                                  TextStyle(
                                      color: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.4)),
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
                              UiIcons.phone_call,
                              color:
                                  Theme.of(context).focusColor.withOpacity(0.4),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        FlatButton(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 70),
                          onPressed: () async {
                            EasyLoading.show(status: 'Loading...');
                            var email = myEmailController.text;
                            var password = myPasswordController.text;
                            var name = myNameController.text;
                            var phone = myPhoneController.text;

                            var res = await http.post(
                                Uri.parse(SERVER_DOMAIN + 'register'),
                                body: {
                                  'email': email,
                                  'password': password,
                                  'name': name,
                                  'phone': phone
                                });

                            if (res.statusCode == 200) {
                              EasyLoading.dismiss();
                              _showMyDialog(
                                  'Register successful!, Please check your email.',
                                  'signIn');
                            } else {
                              EasyLoading.dismiss();
                              _showMyDialog(
                                  'Please check your data again!', 'pop');
                            }
                          },
                          child: Text(
                            'Sign Up',
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
                Navigator.of(context).pushNamed('/SignIn');
              },
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.title.merge(
                        TextStyle(color: Theme.of(context).primaryColor),
                      ),
                  children: [
                    TextSpan(text: 'Already have an account ?'),
                    TextSpan(
                        text: ' Sign In',
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
