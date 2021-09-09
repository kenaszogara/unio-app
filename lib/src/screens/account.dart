import 'dart:convert';
import 'dart:io';

import 'package:Unio/src/providers/countries.dart';
import 'package:Unio/src/providers/level.dart';
import 'package:Unio/src/utilities/global.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../config/ui_icons.dart';
import '../models/user.dart';
import '../widgets/ProfileSettingsDialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AccountWidget extends StatefulWidget {
  @override
  _AccountWidgetState createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
  User _user = new User.init().getCurrentUser();

  dynamic countryRes;
  List<String> countryList = [];
  String _selectedCountryName;
  int _selectedCountryId;

  dynamic levelRes;
  List<String> levelList = [];
  String _selectedLevelName;
  int _selectedLevelId;

  @override
  void initState() {
    super.initState();

    context.read<LevelProvider>().initLevel();
    context.read<CountryProvider>().initCountries();

    // if (Global.instance.authCountryId == null) {
    //   _selectedCountryId = -1;
    //   _selectedCountryName = 'Any Country';
    // } else {
    //   _selectedCountryId = Global.instance.authCountryId;
    // }

    // if (Global.instance.authLevelId == null) {
    //   _selectedLevelId = -1;
    //   _selectedLevelName = 'Any Degree';
    // } else {
    //   _selectedLevelId = Global.instance.authLevelId;
    // }

    // getCountry();
    // getLevel();
  }

  void getCountry() async {
    http.get(
        Uri.parse('https://primavisiglobalindo.net/unio/public/api/countries'),
        // Send authorization headers to the backend.
        headers: {
          // HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'aplication/json',
        }).then((response) {
      print(response.body);

      countryRes = jsonDecode(response.body)['data'];

      for (var i = 0; i < countryRes.length; i++) {
        setState(() {
          countryList.add(countryRes[i]['name'].toString());
          if (_selectedCountryId == countryRes[i]['id']) {
            _selectedCountryName = countryRes[i]['name'];
          }
        });
      }
    });
  }

  void getLevel() async {
    http.get(
        Uri.parse(
            'https://primavisiglobalindo.net/unio/public/api/level_major'),
        // Send authorization headers to the backend.
        headers: {
          // HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'aplication/json',
        }).then((response) {
      print(response.body);

      levelRes = jsonDecode(response.body)['data'];

      for (var i = 0; i < levelRes.length; i++) {
        setState(() {
          levelList.add(levelRes[i]['name'].toString());
          if (_selectedLevelId == levelRes[i]['id']) {
            _selectedLevelName = levelRes[i]['name'];
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _levelProvider = context.watch<LevelProvider>();
    final _countryProvider = context.watch<CountryProvider>();

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
                        leading: Icon(UiIcons.loupe),
                        title: Text(
                          'Search Preference Settings',
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          // Navigator.of(context).pushNamed('/Languages');
                        },
                        dense: true,
                        leading: Icon(
                          UiIcons.planet_earth,
                          size: 22,
                          color: Theme.of(context).focusColor,
                        ),
                        title: Container(
                          height: 55.0,
                          child: _dropDown(
                              label: 'Country',
                              hint: 'Country',
                              items: _countryProvider.countries,
                              selectedItem: _countryProvider.selectedCountry,
                              onChanged: (value) {
                                _countryProvider.selectedCountry = value;
                                if (value != null) {
                                  print("nilai=" + value.toString());
                                  _countryProvider.addDefault(context);
                                } else {
                                  _countryProvider.removeDefault(context);
                                }
                              }),
                        ),
                      ),
                      ListTile(
                        onTap: () {
                          // Navigator.of(context).pushNamed('/Help');
                        },
                        dense: true,
                        leading: Icon(
                          FontAwesomeIcons.graduationCap,
                          size: 22,
                          color: Theme.of(context).focusColor,
                        ),
                        title: _dropDown(
                            hint: 'Level Degree',
                            selectedItem: _selectedLevelName,
                            items: levelList,
                            onChanged: (value) {
                              _levelProvider.selectedLevel = value;
                              if (value == null) {
                                _levelProvider.addDefault(context);
                              } else {
                                _levelProvider.removeDefault(context);
                              }
                            }),
                      ),
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

  Future<void> updateProfile() async {
    Map<String, String> headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json'
    };
    var url = SERVER_DOMAIN + 'users/' + Global.instance.authId;
    var token = Global.instance.apiToken;
    headers.addAll(
        <String, String>{HttpHeaders.authorizationHeader: 'Bearer $token'});
    print(url);
    print(headers);

    final client = new http.Client();

    final response = await client.put(Uri.parse(url),
        headers: headers,
        body: jsonEncode(
            {'country_id': _selectedCountryId, 'level_id': _selectedLevelId}));
    print(response.body);

    var msg = jsonDecode(response.body)['message'];

    if (response.statusCode == 200) {
      Global.instance.authCountryId = _selectedCountryId;
      Global.instance.authLevelId = _selectedLevelId;

      // print(Global.instance.authCountryId);

      storage.write(key: 'authCountryId', value: _selectedCountryId.toString());
      storage.write(key: 'authLevelId', value: _selectedLevelId.toString());

      showOkAlertDialog(context: context, title: msg);
    } else {
      showOkAlertDialog(context: context, title: 'Update not successful');
    }
  }

  Widget _dropDown({items, label, hint, onChanged, selectedItem}) {
    return DropdownSearch<String>(
      mode: Mode.BOTTOM_SHEET,
      showSelectedItem: true,
      showSearchBox: true,
      showClearButton: true,
      items: items,
      label: label,
      hint: hint,
      onChanged: onChanged,
      selectedItem: selectedItem,
      dropdownSearchDecoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
      ),

      // TODOS: FIGURE OUT HOW TO RE BUILD THIS
      dropdownButtonBuilder: (context) {
        return Container(
          child: Icon(Icons.arrow_drop_down,
              size: 20, color: Theme.of(context).hintColor.withOpacity(0.5)),
        );

        // return SizedBox();
      },

      clearButtonBuilder: (context) {
        return Container(
          padding: EdgeInsets.only(right: 10.0),
          child: Icon(UiIcons.trash,
              size: 20, color: Theme.of(context).hintColor.withOpacity(0.5)),
        );
      },

      emptyBuilder: (context, text) {
        return Container(
          alignment: Alignment.center,
          child: Text(
            'No data found',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        );
      },
      searchBoxDecoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.blue.shade100,
          ),
        ),
      ),
    );
  }
}
