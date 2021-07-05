import 'package:Unio/src/utilities/global.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/ui_icons.dart';
import '../models/user.dart';
import '../widgets/ProfileSettingsDialog.dart';
import 'package:flutter/material.dart';

class AccountWidget extends StatefulWidget {
  @override
  _AccountWidgetState createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  User _user = new User.init().getCurrentUser();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                        _user.name,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.display2,
                      ),
                      (Global.instance.apiToken != null)
                          ? Text(
                              _user.email,
                              style: Theme.of(context).textTheme.caption,
                            )
                          : SizedBox(),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                SizedBox(
                    width: 55,
                    height: 55,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(300),
                      onTap: () {
                        Navigator.of(context).pushNamed('/Tabs', arguments: 1);
                      },
                      child: (!_user.hasPicture(Global.instance.authPicture))
                          ? CircleAvatar(
                              child: Icon(FontAwesomeIcons.user),
                            )
                          : CircleAvatar(
                              backgroundColor: Theme.of(context).accentColor,
                              backgroundImage: NetworkImage(_user.avatar),
                            ),
                    )),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).hintColor.withOpacity(0.15),
                    offset: Offset(0, 3),
                    blurRadius: 10)
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    onPressed: () {
                      if (Global.instance.apiToken != null) {
                        Navigator.of(context).pushNamed('/Questionnaire');
                      } else {
                        _showNeedLoginAlert(context);
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.userEdit,
                          color: Theme.of(context).focusColor,
                        ),
                        Text(
                          'Questionnaire',
                          style: Theme.of(context).textTheme.body1,
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    onPressed: () {
                      if (Global.instance.apiToken != null) {
                        Navigator.of(context).pushNamed('/Bookmark');
                      } else {
                        _showNeedLoginAlert(context);
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.solidHeart,
                          color: Theme.of(context).focusColor,
                        ),
                        Text(
                          'Bookmark',
                          style: Theme.of(context).textTheme.body1,
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    onPressed: () {
                      showOkAlertDialog(
                        context: context,
                        title: 'This feature is under development.',
                      );
                      //Navigator.of(context).pushNamed('/Tabs', arguments: 0);
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.shoppingCart,
                          color: Theme.of(context).focusColor,
                        ),
                        Text(
                          'Cart',
                          style: Theme.of(context).textTheme.body1,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).hintColor.withOpacity(0.15),
                    offset: Offset(0, 3),
                    blurRadius: 10)
              ],
            ),
            child: (Global.instance.apiToken != null)
                ? ListView(
                    shrinkWrap: true,
                    primary: false,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(UiIcons.user_1),
                        title: Text(
                          'Profile Settings',
                          style: Theme.of(context).textTheme.body2,
                        ),
                        trailing: ButtonTheme(
                          padding: EdgeInsets.all(0),
                          minWidth: 50.0,
                          height: 25.0,
                          child: ProfileSettingsDialog(
                            user: this._user,
                            onChanged: () {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        dense: true,
                        title: Text(
                          'Full name',
                          style: Theme.of(context).textTheme.body1,
                        ),
                        trailing: Text(
                          _user.name,
                          style: TextStyle(color: Theme.of(context).focusColor),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        dense: true,
                        title: Text(
                          'Email',
                          style: Theme.of(context).textTheme.body1,
                        ),
                        trailing: Text(
                          _user.email,
                          style: TextStyle(color: Theme.of(context).focusColor),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        dense: true,
                        title: Text(
                          'Sex',
                          style: Theme.of(context).textTheme.body1,
                        ),
                        trailing: Text(
                          _user.gender,
                          style: TextStyle(color: Theme.of(context).focusColor),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        dense: true,
                        title: Text(
                          'Birth Date',
                          style: Theme.of(context).textTheme.body1,
                        ),
                        trailing: Text(
                          _user.getDateOfBirth(),
                          style: TextStyle(color: Theme.of(context).focusColor),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        dense: true,
                        title: Text(
                          'Birth Place',
                          style: Theme.of(context).textTheme.body1,
                        ),
                        trailing: Text(
                          _user.birthPlace,
                          style: TextStyle(color: Theme.of(context).focusColor),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        dense: true,
                        title: Text(
                          'Address',
                          style: Theme.of(context).textTheme.body1,
                        ),
                        trailing: Text(
                          _user.address,
                          style: TextStyle(color: Theme.of(context).focusColor),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        dense: true,
                        title: Text(
                          'Phone Number',
                          style: Theme.of(context).textTheme.body1,
                        ),
                        trailing: Text(
                          _user.phone,
                          style: TextStyle(color: Theme.of(context).focusColor),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        dense: true,
                        title: Text(
                          'School Origin',
                          style: Theme.of(context).textTheme.body1,
                        ),
                        trailing: Text(
                          _user.school,
                          style: TextStyle(color: Theme.of(context).focusColor),
                        ),
                      ),
                      ListTile(
                        onTap: () {},
                        dense: true,
                        title: Text(
                          'Graduation Year',
                          style: Theme.of(context).textTheme.body1,
                        ),
                        trailing: Text(
                          _user.graduate.toString(),
                          style: TextStyle(color: Theme.of(context).focusColor),
                        ),
                      ),

                      // ListTile(
                      //   onTap: () {},
                      //   dense: true,
                      //   title: Text(
                      //     'Identity Number',
                      //     style: Theme.of(context).textTheme.body1,
                      //   ),
                      //   trailing: Text(
                      //     _user.identity ?? '-',
                      //     style: TextStyle(color: Theme.of(context).focusColor),
                      //   ),
                      // ),
                    ],
                  )
                : SizedBox(),
          ),
          (Global.instance.apiToken == null)
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).hintColor.withOpacity(0.15),
                          offset: Offset(0, 3),
                          blurRadius: 10)
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _showNeedLoginAlert(context);
                    },
                    child: Text('Login'),
                  ),
                )
              : SizedBox(),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).hintColor.withOpacity(0.15),
                    offset: Offset(0, 3),
                    blurRadius: 10)
              ],
            ),
            // child: ListView(
            //   shrinkWrap: true,
            //   primary: false,
            //   children: <Widget>[
            //     ListTile(
            //       leading: Icon(UiIcons.settings_1),
            //       title: Text(
            //         'Account Settings',
            //         style: Theme.of(context).textTheme.body2,
            //       ),
            //     ),
            //     ListTile(
            //       onTap: () {
            //         Navigator.of(context).pushNamed('/Languages');
            //       },
            //       dense: true,
            //       title: Row(
            //         children: <Widget>[
            //           Icon(
            //             UiIcons.planet_earth,
            //             size: 22,
            //             color: Theme.of(context).focusColor,
            //           ),
            //           SizedBox(width: 10),
            //           Text(
            //             'Languages',
            //             style: Theme.of(context).textTheme.body1,
            //           ),
            //         ],
            //       ),
            //       trailing: Text(
            //         'English',
            //         style: TextStyle(color: Theme.of(context).focusColor),
            //       ),
            //     ),
            //     ListTile(
            //       onTap: () {
            //         Navigator.of(context).pushNamed('/Help');
            //       },
            //       dense: true,
            //       title: Row(
            //         children: <Widget>[
            //           Icon(
            //             UiIcons.information,
            //             size: 22,
            //             color: Theme.of(context).focusColor,
            //           ),
            //           SizedBox(width: 10),
            //           Text(
            //             'Help & Support',
            //             style: Theme.of(context).textTheme.body1,
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
          ),
        ],
      ),
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
}
