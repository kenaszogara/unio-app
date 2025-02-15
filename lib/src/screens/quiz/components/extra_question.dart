import 'dart:io';

import 'package:Unio/config/ui_icons.dart';
// import 'package:Unio/src/controllers/question_controller.dart';
import 'package:Unio/src/models/route_argument.dart';
import 'package:Unio/src/utilities/global.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Unio/src/models/category.dart';
// import 'package:get/get.dart';

class ExtraQuestionScreen extends StatefulWidget {
  final RouteArgument routeArgument;
  dynamic oldHc;
  dynamic extraHc;
  dynamic extraQuestions;

  ExtraQuestionScreen({Key key, this.routeArgument}) {
    oldHc = this.routeArgument.argumentsList[0];
    extraHc = this.routeArgument.argumentsList[1];
    extraQuestions = this.routeArgument.argumentsList[2];
  }

  @override
  _ExtraQuestionScreenState createState() => _ExtraQuestionScreenState();
}

class _ExtraQuestionScreenState extends State<ExtraQuestionScreen> {
  dynamic options;
  int order;
  int isClicked;
  dynamic answer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    order = 1;
    isClicked = 0;
    options = [];
    normalizeData();
    // extraHc = _questionController.extraHc;
    // extraQuestions = _questionController.extraQuestions;
  }

  void normalizeData() {
    for (var i = 0; i < widget.extraHc.length; i++) {
      var type = widget.extraHc[i];
      for (var j = 0; j < widget.extraQuestions.length; j++) {
        if (widget.extraQuestions[j]['type'] == type) {
          widget.extraQuestions[j]['order'] = 0;
          options.add(widget.extraQuestions[j]);
        }
      }
    }
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
                            })
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
                      'Please click the picture in order, based on your preference',
                      style: Theme.of(context).textTheme.display1,
                    )),
                ..._extrasThree(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            resetOrder();
                          },
                          child: Text('Reset')),
                      ElevatedButton(
                          onPressed: () {
                            if (order > options.length)
                              // print(order);
                              answerExtra();
                          },
                          child: Text('Done'))
                    ],
                  ),
                )
              ],
            ),
          ))),
    ));
  }

  List<Widget> _extrasThree() {
    List<Widget> _w = [];

    for (var i = 0; i < options.length; i++) {
      _w.add(GestureDetector(
          onTap: () {
            if (options[i]['order'] == 0) {
              setState(() {
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
    });
  }

  void answerExtra() async {
    var tempIndex;

    String hc = '';

    String answer = "";

    String _hcCase = widget.oldHc.replaceAll('_', "");
    int _length = 3 - _hcCase.length;

    for (int i = 0; i < _length; i++) {
      answer = answer + options[i]['type'];
    }

    hc = widget.oldHc.replaceAll('_', answer);

    print(hc);

    try {
      final url =
          Uri.parse('${SERVER_DOMAIN}user/set-hc/${Global.instance.authId}');
      final token = await storage.read(key: 'apiToken');
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
      }, body: {
        'hc': hc,
      });

      print(response);

      // save to local storage
      Global.instance.authHc = hc;
      await storage.write(key: 'authHc', value: hc);

      print('${hc} added to user profile');

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
