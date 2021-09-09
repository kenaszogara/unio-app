import 'dart:io';

import 'package:Unio/config/ui_icons.dart';
import 'package:Unio/src/models/route_argument.dart';
import 'package:Unio/src/utilities/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Unio/src/models/category.dart';

import '../../../../constants.dart';
// import 'package:get/get.dart';

class ExtraQuestionTwoScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  dynamic oldHc;
  dynamic extraHc;
  dynamic extraQuestions;
  dynamic res;

  ExtraQuestionTwoScreen({Key key, this.routeArgument}) {
    oldHc = this.routeArgument.argumentsList[0];
    extraHc = this.routeArgument.argumentsList[1];
    extraQuestions = this.routeArgument.argumentsList[2];
    res = this.routeArgument.argumentsList[3];
  }

  @override
  _ExtraQuestionTwoScreenState createState() => _ExtraQuestionTwoScreenState();
}

class _ExtraQuestionTwoScreenState extends State<ExtraQuestionTwoScreen> {
  dynamic options;
  int order;
  bool isAnswered;
  dynamic answer;
  int extrasLength;
  int currItteration;
  String _score;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    order = 1;
    isAnswered = false;
    options = [];
    extrasLength = widget.res['extra_images'].length;
    _score = widget.res['score'];
    currItteration = 0;
    normalizeData();
    // print('test');
  }

  void normalizeData() {
    dynamic extraImages = widget.extraHc[currItteration];
    // print(extraImages);
    for (var i = 0; i < extraImages.length; i++) {
      // print(extraImages[i]['name']);

      dynamic _op = {
        'name': extraImages[i]['name'],
        'type': extraImages[i]['type'],
        'img': extraImages[i]['src'],
        'order': 0,
      };

      options.add(_op);
    }
    // print(options);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SafeArea(
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: new Icon(UiIcons.return_icon,
                  color: Theme.of(context).hintColor.withOpacity(0.5)),
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Stop Questionaire?'),
                      content: Text(
                          'You will have to restart all the questions. Are you sure?'),
                      actions: [
                        TextButton(
                            child: Text('Yes'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            }),
                        TextButton(
                            child: Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                      ],
                    );
                  }),
            ),
          ),
          body: SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Choose one that suits you best',
                      style: Theme.of(context).textTheme.display1,
                    )),
                ...(options.length == 2) ? _extrasTwo() : _extrasThree(),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (options.length > 2)
                          ? ElevatedButton(
                              onPressed: () {
                                resetOrder();
                              },
                              child: Text('Reset'))
                          : SizedBox(),
                      ElevatedButton(
                          onPressed: () {
                            if (isAnswered)
                              // print(order);
                              answerExtra();
                          },
                          child: (currItteration < extrasLength - 1)
                              ? Text('Next')
                              : Text('Done'))
                    ],
                  ),
                )
              ],
            ),
          ))),
    ));
  }

  Color getTheRightColor(option) {
    if (option['order'] == 1) {
      return kGreenColor;
    }
    return kGrayColor;
  }

  IconData getTheRightIcon(option) {
    return getTheRightColor(option) == kRedColor ? Icons.close : Icons.done;
  }

  List<Widget> _extrasTwo() {
    List<Widget> _w = [];

    for (var i = 0; i < options.length; i++) {
      _w.add(GestureDetector(
          onTap: () {
            setState(() {
              isAnswered = true;
              if (options[i]['order'] == 2 || options[i]['order'] == 0) {
                options[i]['order'] = 1;
                options[(i + 1) % 2]['order'] = 2;
              }
            });
          },
          child: Container(
            margin: EdgeInsets.only(top: kDefaultPadding),
            padding: EdgeInsets.all(kDefaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              border: Border.all(color: getTheRightColor(options[i]), width: 1),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: getTheRightColor(options[i]).withOpacity(0.30),
                    offset: Offset(0, 4),
                    blurRadius: 15)
              ],
            ),
            child: Column(
              children: <Widget>[
                Text(options[i]['name']),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      options[i]['img'],
                      height: 100,
                      width: 200,
                    ),
                    //Image.asset("assets/" + text),
                    /*Text(
                        "${index + 1}. $text",
                        style: TextStyle(color: getTheRightColor(), fontSize: 16),
                      ),*/
                    Container(
                      height: 26,
                      width: 26,
                      decoration: BoxDecoration(
                        color: getTheRightColor(options[i]) == kGrayColor
                            ? Colors.transparent
                            : getTheRightColor(options[i]),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: getTheRightColor(options[i])),
                      ),
                      child: getTheRightColor(options[i]) == kGrayColor
                          ? null
                          : Icon(getTheRightIcon(options[i]), size: 16),
                    )
                  ],
                ),
              ],
            ),
          )));
    }

    return _w;
  }

  List<Widget> _extrasThree() {
    List<Widget> _w = [];

    for (var i = 0; i < options.length; i++) {
      _w.add(GestureDetector(
          onTap: () {
            if (options[i]['order'] == 0) {
              setState(() {
                isAnswered = true;
                if (order <= options.length) {
                  options[i]['order'] = order;
                  order = order + 1;
                }
              });
            } else {
              resetOrder();
            }
          },
          child: Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Container(
                // width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(20),
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
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    (options[i]['order'] != 0)
                        ? Positioned(
                            top: -30,
                            right: -30,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Color(0xFF007BFF),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                options[i]['order'].toString(),
                                style: TextStyle(
                                    color: Color(0xFFEBE8E7),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          )
                        : SizedBox(),
                    Column(
                      children: [
                        Text(options[i]['name']),
                        SizedBox(
                          height: 10,
                        ),
                        Image.network(
                          options[i]['img'],
                          height: 100,
                          width: 200,
                        ),
                      ],
                    )
                  ],
                ),
              ))));
    }

    return _w;
  }

  void resetOrder() {
    setState(() {
      for (var i = 0; i < options.length; i++) {
        options[i]['order'] = 0;
      }
      order = 1;
      isAnswered = false;
    });
  }

  void answerExtra() async {
    // var tempIndex;
    String _hc = '';
    String _answer = "";

    int _slot = 3 - _score.replaceFirst('_', '').length;

    // sort answer by order
    for (var i = 0, j = 1; i < _slot; i++, j++) {
      for (var item in options) {
        if (item['order'] == j) {
          _answer = _answer + item['type'].toString();
        }
      }
    }
    // print(_slot);
    // print(_answer);
    _hc = _score.replaceFirst('_', _answer);
    print(_hc);

    if (currItteration < extrasLength - 1) {
      setState(() {
        _score = _hc;
        currItteration++;
        resetOrder();
        options = [];
        normalizeData();
      });
    } else {
      try {
        final url =
            Uri.parse('${SERVER_DOMAIN}user/set-hc/${Global.instance.authId}');
        final token = await storage.read(key: 'apiToken');
        final response = await http.post(url, headers: {
          'Authorization': 'Bearer $token',
        }, body: {
          'hc': _hc,
        });

        print(response);

        // save to local storage
        Global.instance.authHc = _hc;
        await storage.write(key: 'authHc', value: _hc);

        print('$_hc added to user profile');

        Navigator.of(context).pushReplacementNamed('/Advice',
            arguments: new RouteArgument(argumentsList: [
              Category(
                  'Match With Me', UiIcons.compass, true, Colors.redAccent, []),
              ''
            ]));
      } on SocketException {
        throw 'Tidak ada koneksi internet. Silahkan coba lagi.';
      }
    }
  }
}
