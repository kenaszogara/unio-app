import 'package:Unio/src/utilities/global.dart';

import '../../config/ui_icons.dart';
import 'package:flutter/material.dart';
import 'package:Unio/main.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/category.dart';
import '../models/utilities.dart';
import '../models/route_argument.dart';
import 'package:Unio/src/screens/quiz/quiz_screen.dart';
import 'package:get/get.dart';

class SearchBarHomeWidget extends StatefulWidget {
  // final TextEditingController _controller = TextEditingController();
  SearchBarHomeWidget({
    Key key,
  }) : super(key: key);

  @override
  _SearchBarHomeWidgetState createState() => _SearchBarHomeWidgetState();
}

class _SearchBarHomeWidgetState extends State<SearchBarHomeWidget> {
  List<String> suggestions = [];

  final myController = TextEditingController();

  CategoriesList _categoriesList = new CategoriesList();

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
                Navigator.of(context).pushNamed('/SignIn');
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
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).hintColor.withOpacity(0.10),
              offset: Offset(0, 4),
              blurRadius: 10)
        ],
      ),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).hintColor.withOpacity(0.4),
                    width: 1),
                borderRadius: BorderRadius.circular(10.0)),
            child: Stack(
              alignment: Alignment.centerRight,
              children: <Widget>[
                TextField(
                  // controller:_controller,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'Search',
                    hintStyle: TextStyle(
                        color: Theme.of(context).focusColor.withOpacity(0.8)),
                    // prefixIcon: Icon(UiIcons.loupe,
                    //     size: 20, color: Theme.of(context).hintColor),
                    border: UnderlineInputBorder(borderSide: BorderSide.none),
                    enabledBorder:
                        UnderlineInputBorder(borderSide: BorderSide.none),
                    focusedBorder:
                        UnderlineInputBorder(borderSide: BorderSide.none),
                  ),
                  controller: myController,
                ),
                // Padding(
                //   padding: const EdgeInsets.only(right:30.0),
                //   child: IconButton(
                //     onPressed: () {
                //       // Scaffold.of(context).openEndDrawer();
                //     },
                //     icon: Icon(UiIcons.checked,
                //         size: 20,
                //         color: Theme.of(context).hintColor.withOpacity(0.5)),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: IconButton(
                    onPressed: () async {
                      Navigator.of(context).pushNamed('/Directory',
                          arguments: new RouteArgument(argumentsList: [
                            Category('University', UiIcons.laptop, false,
                                Colors.orange, []),
                            myController.text
                          ]));
                    },
                    icon: Icon(UiIcons.loupe,
                        size: 20,
                        color: Theme.of(context).hintColor.withOpacity(0.5)),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    cari_keyword = myController.text;
                    Scaffold.of(context).openEndDrawer();
                  },
                  icon: Icon(UiIcons.settings_2,
                      size: 20,
                      color: Theme.of(context).hintColor.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlatButton(
                onPressed: () async {
                  if (Global.instance.apiToken == null) {
                    _showNeedLoginAlert(context);
                  } else {

                    // Map<String, String> headers = <String, String>{
                    //   HttpHeaders.contentTypeHeader: 'application/json'
                    // };
                    // var url = SERVER_DOMAIN + 'users/' + Global.instance.authId;
                    // var token = Global.instance.apiToken;
                    // headers.addAll(
                    //     <String, String>{HttpHeaders.authorizationHeader: 'Bearer $token'});
                    // print(url);
                    // print(headers);

                    // final client = new http.Client();
                    // final response = await client.get(Uri.parse(url),
                    //     headers: headers,
                    // );
                    // print(response.body);
                    // var hasil = jsonDecode(response.body);

                    if (Global.instance.authHc == '') {
                      print(Global.instance.authHc);
                      print("questionary");
                      Get.to(() => QuizScreen());
                    } else {
                      print("advices");
                      Navigator.of(context).pushNamed('/Advice',
                          arguments: new RouteArgument(argumentsList: [
                            Category('Advice', UiIcons.compass, true,
                                Colors.redAccent, []),
                            ''
                          ]));
                    }

                    // Map<String, String> headers = <String, String>{
                    //   HttpHeaders.contentTypeHeader: 'application/json'
                    // };

                    // url = SERVER_DOMAIN + 'match-with-me/' + Global.instance.authId;
                    // token = Global.instance.apiToken;
                    // headers.addAll(
                    //     <String, String>{HttpHeaders.authorizationHeader: 'Bearer $token'});
                    // print(url);
                    // print(headers);
                    //
                    // // client = new http.Client();
                    // final response2 = await client.get(Uri.parse(url),
                    //   headers: headers,
                    // );
                    // print(response2.body);

                    // if (response.statusCode == 200) return response.body;

                    // Navigator.of(context).pushNamed('/Advice',
                    //     arguments: new RouteArgument(argumentsList: [
                    //       Category('Advice', UiIcons.compass, true,
                    //           Colors.redAccent, []),
                    //       ''
                    //     ]));
                  }
                },
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                color: Theme.of(context).backgroundColor,
                shape: StadiumBorder(),
                child: Text(
                  'Match with me',
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: _buildSuggestions(suggestions, context),
          )
        ],
      ),
    );
  }
}

_buildSuggestions(List<String> list, BuildContext context) {
  List<Widget> choices = List();
  list.forEach((item) {
    choices.add(
      Container(
        margin: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Theme.of(context).hintColor.withOpacity(0.2),
          ),
          padding:
              const EdgeInsets.only(left: 10.0, right: 10, top: 3, bottom: 3),
          child: Text(
            item,
            style: Theme.of(context).textTheme.body1.merge(
                  TextStyle(color: Theme.of(context).primaryColor),
                ),
          ),
        ),
      ),
    );
  });
  return choices;
}
