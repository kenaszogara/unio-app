import 'package:Unio/src/screens/quiz/quiz_screen.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../config/ui_icons.dart';
import '../models/user.dart';
import 'package:flutter/material.dart';
import 'package:Unio/src/utilities/global.dart';

// ignore: must_be_immutable
class DrawerWidget extends StatelessWidget {
  User _user = new User.init().getCurrentUser();

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log out'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Are you sure? logging out will remove all Unio data from this device.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                // storage.deleteAll();
                // Global.instance.apiToken = null;
                // Global.instance.authName = 'Guest';
                // Global.instance.authEmail = null;
                // _user.logoutUser();

                storage.deleteAll();

                Global.instance.authId = null;
                Global.instance.authName = 'Guest User';
                Global.instance.apiToken = null;
                Global.instance.authEmail = null;
                Global.instance.authGender = null;
                Global.instance.authBirthDate = null;
                Global.instance.authBirthPlace = null;
                Global.instance.authPicture = null;
                Global.instance.authAddress = null;
                Global.instance.authPhone = null;
                Global.instance.authSchool = null;
                Global.instance.authGraduate = null;
                Global.instance.authIdentity = null;
                Global.instance.authReligion = null;

                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/Tabs');
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showNeedLoginAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You are not logged in!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you wanna login first?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).popAndPushNamed('/SignIn');
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/Setting');
            },
            child: UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).hintColor.withOpacity(0.1),
              ),
              accountName: Text(
                (Global.instance.authName != null)
                    ? Global.instance.authName
                    : 'Guest User',
                style: Theme.of(context).textTheme.title,
              ),
              accountEmail: (Global.instance.authEmail != null)
                  ? Text(
                      Global.instance.authEmail,
                      style: Theme.of(context).textTheme.caption,
                    )
                  : null,
              currentAccountPicture:
                  (!_user.hasPicture(Global.instance.authPicture))
                      ? CircleAvatar(
                          child: Icon(FontAwesomeIcons.user),
                          //child: Text(_user.initials()),
                        )
                      : CircleAvatar(
                          backgroundColor: Theme.of(context).accentColor,
                          backgroundImage: NetworkImage(_user.avatar),
                        ),
            ),
          ),
          // ListTile(
          //   onTap: () {
          //     Navigator.of(context).pushNamed('/Tabs', arguments: 0);
          //   },
          //   leading: Icon(
          //     UiIcons.home,
          //     color: Theme.of(context).focusColor.withOpacity(1),
          //   ),
          //   title: Text(
          //     "Home",
          //     style: Theme.of(context).textTheme.subhead,
          //   ),
          // ),
          // ListTile(
          //   onTap: () {
          //     Navigator.of(context).pushNamed('/Tabs', arguments: 0);
          //   },
          //   leading: Icon(
          //     UiIcons.bell,
          //     color: Theme.of(context).focusColor.withOpacity(1),
          //   ),
          //   title: Text(
          //     "Notifications",
          //     style: Theme.of(context).textTheme.subhead,
          //   ),
          // ),
          ListTile(
            onTap: () {
              (Global.instance.apiToken != null)
                  ? Navigator.of(context).pushNamed('/Bookmark')
                  : _showNeedLoginAlert(context);
            },
            leading: Icon(
              FontAwesomeIcons.solidHeart,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              "Bookmark",
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          ListTile(
            onTap: () {
              if (Global.instance.apiToken != null) {
                Get.to(() => QuizScreen());
              } else {
                _showNeedLoginAlert(context);
              }
            },
            leading: Icon(
              FontAwesomeIcons.userEdit,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              "Questionnaire",
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          // ListTile(
          //   onTap: () {
          //     showOkAlertDialog(
          //       context: context,
          //       title: 'This feature is under development.',
          //     );
          //     //Navigator.of(context).pushNamed('/Categories');
          //   },
          //   leading: Icon(
          //     UiIcons.folder_1,
          //     color: Theme.of(context).focusColor.withOpacity(1),
          //   ),
          //   title: Text(
          //     "Categories",
          //     style: Theme.of(context).textTheme.subhead,
          //   ),
          // ),
          ListTile(
            dense: true,
            title: Text(
              "Application Preferences",
              style: Theme.of(context).textTheme.body1,
            ),
            trailing: Icon(
              Icons.remove,
              color: Theme.of(context).focusColor.withOpacity(0.3),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/Setting');
            },
            leading: Icon(
              FontAwesomeIcons.cog,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              "Settings",
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          // ListTile(
          //   onTap: () {
          //     Navigator.of(context).pushNamed('/Languages');
          //   },
          //   leading: Icon(
          //     UiIcons.planet_earth,
          //     color: Theme.of(context).focusColor.withOpacity(1),
          //   ),
          //   title: Text(
          //     "Languages",
          //     style: Theme.of(context).textTheme.subhead,
          //   ),
          // ),
          ListTile(
            onTap: () {
              Global.instance.apiToken != null
                  ? _showLogoutDialog(context)
                  : Navigator.of(context).pushNamed('/SignIn');
            },
            leading: Icon(
              Global.instance.apiToken != null
                  ? UiIcons.return_icon
                  : UiIcons.user_1,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              Global.instance.apiToken != null ? "Log Out" : "Log In",
              style: Theme.of(context).textTheme.subhead,
            ),
          ),
          /*ListTile(
            dense: true,
            title: Text(
              "Version 0.0.1",
              style: Theme.of(context).textTheme.body1,
            ),
            trailing: Icon(
              Icons.remove,
              color: Theme.of(context).focusColor.withOpacity(0.3),
            ),
          ),*/
        ],
      ),
    );
  }
}
